class S2bBoardsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :load_settings
  before_filter :validate_conditions
  #before_filter :find_issue,          :except => [:index, :create, :filter_issues_onboard]
  before_filter :check_before_board,  :only   => [:index, :filter_issues_onboard,
                                                  :update, :create, :edit]
  
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
 
 
 
 
  def edit
    @issue = Issue.find(params[:issue_id])
    return if @issue.blank? 
    edit = render_to_string(:partial => "/s2b_boards/form_edit", :locals => {:issue => @issue, 
        :members => @members, :priorities => @priorities, :sprints => @sprints})
    render :json => {:result => "success", :content => edit}
  end
 
 
 
  def index
    cookies[:view_issue] = { :value => "board", :expires => 1.hour.from_now }
    blank_conditions = false
    blank_conditions = true if session[:conditions].blank? || session[:conditions] == ["true"]
    if @sprint_use_default
      if blank_conditions || cookies[:params_project_ids].blank?
        if @project.blank?
          cookies[:params_project_ids] = { :value => @projects.first.id.to_s.to_a, 
              :expires => 1.hour.from_now }
          flash[:notice] = l(:notice_project_changed_to) + "#{@projects.first.name}"
        else
          cookies[:params_project_ids] = { :value => @project.id.to_s.to_a, 
              :expires => 1.hour.from_now }
          flash[:notice] = l(:notice_project_changed_to) + "#{@project.name}"
        end
      end
    else
      if blank_conditions
        cookies[:params_sprint_custom_values] = { :value => @current_sprint.to_s.to_a, 
            :expires => 1.hour.from_now }
        cookies[:conditions_valid] = { :value => true, :expires => 1.hour.from_now }
        flash[:notice] = l(:notice_sprint_changed_to) + "#{@current_sprint}"
      end
    end
      
    filter_issues
  end
  
  
  
  # Had to get rid of 'done ratio' stuff
  def update_status
    @issue = Issue.find(params[:issue_id])
    return if @issue.blank? 
    create_journal
    unless params[:status].blank?
      new_status = params[:status].to_f.to_i
      new_status = @board_columns[new_status][:status_ids].first.to_i
      @issue.status_id = new_status
    end
    if @issue.save
      sort(params)
      render :json => {:result => "success", :message => "Issue updated."}
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages}
    end
  end
  
  
  
  def update_progress
    @issue = Issue.find(params[:issue_id])
    return if @issue.blank?
    create_journal
    @issue.update_attribute(:done_ratio, params[:done_ratio])
    sort(params)
    render :json => {:result => "success", :new => "Issue progress updated",
                     :new_ratio => params[:done_ratio]}
  end



  def update
    @issue = Issue.find(params[:issue_id])
    return if @issue.blank?
    create_journal
    @issue.subject = params[:subject]
    @issue.priority_id = params[:priority] unless params[:version].blank?
    @issue.assigned_to_id = params[:assignee]
    @issue.estimated_hours = params[:time]
    @issue.description = params[:description] 
    @issue.start_date = params[:date_start]
    @issue.due_date = params[:date_end] 
    @issue.fixed_version_id = params[:version] unless params[:version].blank?
    
    unless params[:sprint_custom_value].blank?
      cfv = @issue.get_custom_field_value(@sprint_custom_field)
      cfv.value = params[:sprint_custom_value] unless cfv.blank?
    end
    
    unless params[:priority_custom_value].blank?
      cfv = @issue.get_custom_field_value(@priority_custom_field)
      cfv.value = params[:priority_custom_value] unless cfv.blank?
    end
    
    if validate_issue(@issue) && @issue.save
      data  = render_to_string(:partial => "/s2b_boards/show_issue", 
                               :locals => {:issue => @issue})
      edit  = render_to_string(:partial => "/s2b_boards/form_new", 
                               :locals => {:issue => @issue, :trackers => @trackers, 
                               :member => @members,
                               :statuses => @statuses, :priorities => @priorities, 
                               :sprints => @sprints})
      render :json => {:result => "edit_success", :message => "Success to update the message",
                       :content => data, :edit_content => edit }
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages,
                       :content => data, :edit_content => edit }
    end
  end
  
  
  
  def create
    @sorted_issues = Issue.where(:status_id => @board_columns.first[:status_ids])
    unless @sprint_use_default
      @sorted_issues = @sorted_issues.eager_load(:custom_values, {
          :project => :issue_custom_fields})
      @sorted_issues = @sorted_issues.where(:custom_values => {
          :custom_field_id => @sprint_custom_field.id})
    end
    @sorted_issues = @sorted_issues.where(session[:conditions]).order(:s2b_position)
    @issue = Issue.new(:subject => params[:subject], :description => params[:description],
        :tracker_id => params[:tracker], :project_id => params[:project], 
        :status_id => params[:status], :assigned_to_id => params[:assignee],
        :priority_id => params[:priority], :fixed_version_id => params[:version], 
        :start_date => params[:date_start], :due_date => params[:date_end], 
        :estimated_hours => params[:time], :author_id => User.current.id,
        :done_ratio => 0, :is_private => false, :lock_version => 0, :s2b_position => 1)
    if @issue.save
      unless params[:sprint_custom_value].blank?
        cfv = @issue.get_custom_field_value(@sprint_custom_field)
        cfv.value = params[:sprint_custom_value] unless cfv.blank?
      end
      @issue.update_attribute(:s2b_position, @sorted_issues.first.s2b_position.to_i - 1)
      data = render_to_string(:partial => "/s2b_boards/board_issue", :locals => {
          :issue => @issue, :trackers => @trackers, :members => @members,
          :statuses => @statuses, :priorities => @priorities, :sprints => @sprints})
      render :json => {:result => "create_success", :message => "Issue successfully created",
          :content => data, :id => @issue.id}
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages}
    end
  end
    
    
  
  def filter_issues_onboard
    if @use_version_form_sprint
      cookies[:params_version_ids] = { :value => params[:version_ids].to_s.split(",").to_a, 
          :expires => 1.hour.from_now } 
    else
      cookies[:params_sprint_custom_values] = { 
          :value => params[:sprint_custom_values].to_s.split(",").to_a,
          :expires => 1.hour.from_now }
    end
    cookies[:params_member_ids] = { :value => params[:member_ids].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }
    cookies[:params_project_ids] = { :value => params[:project_ids].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }
    cookies[:params_status_ids] = { :value => params[:status_ids].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }

    filter_issues
    
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_boards/screen_board", 
            :locals => { :projects => @projects, :trackers => @trackers,
            :priorities => @priorities, :members => @members, :issue => @issue, 
            :statuses => @statuses, :sprints => @sprints, :board_columns => @board_columns })
      }
    end
  end
  
  
  
  
  private
  
  def check_before_board
    @issue = Issue.new
    if @priority_use_default
      @priorities = IssuePriority.all
    else
      @priorities = @priority_custom_field.possible_values
    end
    @trackers = Tracker.all
    @statuses = IssueStatus.sorted
    if @sprint_use_default
      @projects = Project.order(:name)
      @members = User.where(:id => Member.where(:project_id => @projects.pluck("projects.id")
          ).pluck(:user_id).uniq).order(:firstname)
      @sprints = Version.where(project_id: @projects.pluck(:id))
    else
      if @sprint_custom_field.is_for_all
        @projects = Project.order(:name)
      else
        @projects = Project.joins(:issue_custom_fields).where(:custom_fields => 
            {:id => @sprint_custom_field.id}).order("projects.name")
      end
      @members = User.where(:id => Member.where(:project_id => @projects.pluck("projects.id")
          ).pluck(:user_id).uniq).order(:firstname)
      @sprints = @sprint_custom_field.possible_values
    end
    @has_permission = true if !User.current.anonymous? && @members.include?(User.current) || User.current.admin
  end
  
  
  
  def create_journal
    @issue.init_journal(User.current)
  end
  


  def filter_issues
    # Sets conditions based on what user selects in filters
    conditions = ["true"]
    unless cookies[:params_version_ids].blank?
      conditions[0] += " AND issues.fixed_version_id IN (?)"
      conditions << cookies[:params_version_ids]
    end
    unless cookies[:params_project_ids].blank?
      conditions[0] += " AND issues.project_id IN (?)"
      conditions << cookies[:params_project_ids]
    end
    unless cookies[:params_member_ids].blank?
      conditions[0] += " AND issues.assigned_to_id IN (?)"
      conditions << cookies[:params_member_ids]
    end
    unless cookies[:params_status_ids].blank?
      conditions[0] += " AND issues.status_id IN (?)"
      conditions << cookies[:params_status_ids]
    end
    unless cookies[:params_sprint_custom_values].blank? || @sprint_custom_field.blank?
      conditions[0] += " AND custom_values.value IN (?)"
      conditions << cookies[:params_sprint_custom_values]
      conditions[0] += " AND custom_values.custom_field_id = ?"
      conditions << @sprint_custom_field.id
    end
    session[:conditions] = conditions
    cookies[:conditions_valid] = { :value => true, :expires => 1.hour.from_now }
    
    # Assigns positions to all issues without positions.
    max_position_issue = Issue.eager_load(:custom_values).where(
        :status_id => @board_columns.first[:status_ids]).where(
        session[:conditions]).maximum(:s2b_position).to_i + 1
    issue_no_position = Issue.where(:s2b_position => nil)
    issue_no_position.each_with_index do |issue, index|
      issue.update_attribute(:s2b_position, max_position_issue + index)
    end
    
    # Populates each column with issues
    @board_columns.each do |board_column|
      issues = Issue.where("status_id IN (?)", board_column[:status_ids])
      unless @sprint_use_default || cookies[:params_sprint_custom_values].blank?
        issues = issues.joins(:custom_values, {:project => :issue_custom_fields}) 
      end
      issues = issues.where(session[:conditions])
      issues = Issue.where(:id => issues.pluck("issues.id")).eager_load(
          :assigned_to, :tracker, :fixed_version, :status, :project, :custom_values)
      board_column.merge!({:issues => issues.order(:s2b_position)}) 
    end
  end



  # Doesn't work! WHY?!?!?!?
  def find_issue
    @issue = Issue.find(params[:issue_id])
  end



  def find_project
    # @project variable must be set before calling the authorize filter
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id) unless project_id.blank?
    cookies[:params_project_ids] = { :value => @project.id.to_s.to_a, 
        :expires => 1.hour.from_now } unless @project.blank?
  end



  # Reminds user to configure plugin if it hasn't already been configured. 
  def load_settings
    @plugin = Redmine::Plugin.find("scrum2b")
    @settings = Setting["plugin_#{@plugin.id}"]   
    board_columns = @settings["board_columns"]
    sprint_settings = @settings["sprint"]
    priority_settings = @settings["priority"]
    @board_columns = []
    if board_columns.blank? || sprint_settings.blank? || priority_settings.blank?
      flash[:error] = "The system has not been setup to use Scrum2B Tool." + 
          " Please contact to Administrator or go to the Settings page of the plugin: " + 
          "<a href='/settings/plugin/scrum2b'>/settings/plugin/scrum2b</a> to config."
      if @project 
        redirect_to "/projects/#{@project.to_param}"
      else
        redirect_to request.referer
      end
      return
    else
      board_columns.each do |board_column|
        if board_column.last["statuses"].blank?
          flash[:error] = "The Scrum2B board column named '" + board_column.last['name'] + 
              "' has no associated statuses. Please contact an Administrator " + 
              "or go to the Settings page of the plugin: " + 
              "<a href='/settings/plugin/scrum2b'>/settings/plugin/scrum2b</a> to config."
          redirect_to "/projects/#{@project.to_param}"
          return
        else
          @board_columns << {:name => board_column.last["name"], 
              :status_ids => board_column.last["statuses"].keys}
        end
      end 
    end
    
    @show_progress_bars = @settings["show_progress_bars"] == "true"
    @sprint_use_default = sprint_settings["use_default"] == "true"
    @sprint_custom_field = CustomField.find(sprint_settings["custom_field_id"]) unless @sprint_use_default
    @current_sprint = sprint_settings["current_sprint"] unless @sprint_use_default

    @priority_use_default = priority_settings["use_default"] == "true"
    @priority_custom_field = CustomField.find(priority_settings["custom_field_id"]) unless @priority_use_default

    if @sprint_use_default
      unless cookies[:params_sprint_custom_values].blank?
        cookies.delete :params_sprint_custom_values
        cookies.delete :conditions_valid
      end
    else
      unless cookies[:params_version_ids].blank?
        cookies.delete :params_version_ids
        cookies.delete :conditions_valid
      end
    end
  end
  
  
  
  def sort(params)
    @issues_in_column = Issue.eager_load(:assigned_to, :tracker, :fixed_version, :status,
        :custom_values)
    @issue = Issue.find(params[:issue_id])
    @status_ids = [-1]
    @board_columns.each do |board_column|
      @status_ids = board_column[:status_ids]
      break if @status_ids.index(@issue.status_id.to_s)
    end
        
    @issues_in_column = @issues_in_column.where(:status_id => @status_ids)
    @issues_in_column = @issues_in_column.where(session[:conditions]).order(:s2b_position)
    @max_position = @issues_in_column.last.s2b_position.to_i unless @issues_in_column.blank?
    @min_position = @issues_in_column.first.s2b_position.to_i unless @issues_in_column.blank?
    
    if params[:id_next].to_i != 0
      next_issue = Issue.find(params[:id_next].to_i) 
      @next_position = next_issue.s2b_position
    end
    
    if params[:id_prev].to_i != 0
      prev_issue = Issue.find(params[:id_prev].to_i)
      @prev_position = prev_issue.s2b_position
    end
    
    if @next_position.blank? && @prev_position.blank?
       @issue.update_attribute(:s2b_position, 1)
    elsif @next_position.blank? && @prev_position
      @issue.update_attribute(:s2b_position, @max_position + 1)
    elsif @next_position && @prev_position.blank?
      @issue.update_attribute(:s2b_position, @min_position - 1)
    else 
      @issues_in_column = @issues_in_column.where("s2b_position >= ? ", @next_position)
      @issues_in_column.each do |issue|
        issue.update_attribute(:s2b_position,issue.s2b_position + 1) unless issue.id == @issue.id
      end
      @issue.update_attribute(:s2b_position, @next_position)
    end
  end
  
  
  
  def validate_conditions
    session[:conditions] = nil unless cookies[:conditions_valid]
  end
  
  
  
  def validate_issue(issue)
    issue.valid?
    issue.validate_issue
    issue.custom_field_values.each do |cfv|
      cfv.validate_value
    end
    return issue.errors.messages.blank?
  end
  
end
