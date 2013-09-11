class S2bBoardsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :load_settings
  before_filter :check_before_board, :only => [:index, :filter_issues_onboard,
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
    session[:view_issue] = "board"
    
    if session[:conditions].blank? || session[:conditions] == ["true"]
      if @use_version_for_sprint
        if @project.blank?
          session[:params_project_ids] = @projects.first.id.to_s.to_a 
          flash[:notice] = l(:notice_project_changed_to) + "#{@projects.first.name}"
        else
          session[:params_project_ids] = @project.id.to_s.to_a
          flash[:notice] = l(:notice_project_changed_to) + "#{@project.name}"
        end
      else
        session[:params_custom_values] = @current_sprint.to_s.to_a 
        flash[:notice] = l(:notice_sprint_changed_to) + "#{@current_sprint}"
      end
    end
      
    filter_issues
  end
  
  
  
  # Had to get rid of 'done ratio' stuff
  def update_status
    @issue = Issue.find(params[:issue_id])
    return if @issue.blank? || params[:status].blank?
    new_status = params[:status].to_f.to_i
    new_status = @board_columns[new_status][:status_ids].first.to_i
    @issue.update_attributes(:status_id => new_status)
    
    if @issue.valid? 
      data  = render_to_string(:partial => "/s2b_boards/show_issue", 
                               :locals => {:issue => @issue})
      render :json => {:result => "update_success", :message => "Success to update the message",
                       :content => data}
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages,
                       :content => data}
    end
  end
  
  
  
  def update_progress
    @issue = Issue.find(params[:issue_id])
    @issue.update_attribute(:done_ratio, params[:done_ratio])
    render :json => {:result => "success", :new => "Issue progress updated",
                     :new_ratio => params[:done_ratio]}
  end



  def update
    @issue = Issue.find(params[:id_issue])
    @issue.update_attributes(
        :subject => params[:subject], 
        :priority_id => params[:priority],
        :assigned_to_id => params[:assignee],
        :estimated_hours => params[:time],
        :description => params[:description], 
        :start_date => params[:date_start], 
        :due_date => params[:date_end], 
    )
    @issue.update_attribute(:version_id, params[:version]) unless params[:version].blank?
   unless params[:custom_value].blank?
      @issue.custom_values.where(:custom_field_id => @custom_field.id).first.destroy
      cv = CustomValue.new
      cv.customized_type = "Issue"
      cv.value = params[:custom_value]
      cv.custom_field_id = @custom_field.id
      cv.save
      @issue.custom_values << cv
   end
    
    if @issue.valid? 
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
    unless @use_version_for_sprint
      @sorted_issues = @sorted_issues.eager_load(:custom_values, {
          :project => :issue_custom_fields})
      @sorted_issues = @sorted_issues.where(:custom_values => {
          :custom_field_id => @custom_field.id})
    end
    @sorted_issues = @sorted_issues.where(session[:conditions]).order(:s2b_position)
    @issue = Issue.new(:subject => params[:subject], :description => params[:description],
        :tracker_id => params[:tracker], :project_id => params[:project], 
        :status_id => params[:status], :assigned_to_id => params[:assignee],
        :priority_id => params[:priority], :fixed_version_id => params[:version], 
        :start_date => params[:date_start], :due_date => params[:date_end], 
        :estimated_hours => params[:time], :author_id => User.current.id,
        :done_ratio => 0, :is_private => false, :lock_version => 0, :s2b_position => 1)
    cv = CustomValue.new
    cv.customized_type = "Issue"
    cv.value = params[:custom_value]
    cv.custom_field_id = @custom_field.id
    cv.save
    if @issue.save && @issue.custom_values << cv
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
    session[:params_version_ids] = params[:version_ids].to_s.split(",").to_a
    session[:params_member_ids] = params[:member_ids].to_s.split(",").to_a
    session[:params_custom_values] = params[:custom_values].to_s.split(",").to_a
    session[:params_project_ids] = params[:project_ids].to_s.split(",").to_a
    session[:params_status_ids] = params[:status_ids].to_s.split(",").to_a
    
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
  
  
  def find_project
    # @project variable must be set before calling the authorize filter
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id) unless project_id.blank?
    session[:params_project_ids] = @project.id.to_s.to_a unless @project.blank?
  end
  
  
  
  def check_before_board
    @issue = Issue.new
    @priorities = IssuePriority.all
    @trackers = Tracker.all
    @statuses = IssueStatus.sorted
    if @use_version_for_sprint
      @projects = Project.order(:name)
      @members = User.where(:id => Member.where(:project_id => @projects.pluck("projects.id")
          ).pluck(:user_id).uniq).order(:firstname)
      @sprints = Version.where(project_id: @projects.pluck(:id))
    else
      if @custom_field.is_for_all
        @projects = Project.order(:name)
      else
        @projects = Project.joins(:issue_custom_fields).where(:custom_fields => 
            {:id => @custom_field.id}).order("projects.name")
      end
      @members = User.where(:id => Member.where(:project_id => @projects.pluck("projects.id")
          ).pluck(:user_id).uniq).order(:firstname)
      @sprints = @custom_field.possible_values
    end
    @has_permission = true if !User.current.anonymous? && @members.include?(User.current) || User.current.admin
  end
  


  def filter_issues
    session[:conditions] = ["true"]
    unless session[:params_version_ids].blank?
      session[:conditions][0] += " AND issues.fixed_version_id IN (?)"
      session[:conditions] << session[:params_version_ids]
    end
    unless session[:params_project_ids].blank?
      session[:conditions][0] += " AND issues.project_id IN (?)"
      session[:conditions] << session[:params_project_ids]
    end
    unless session[:params_member_ids].blank?
      session[:conditions][0] += " AND issues.assigned_to_id IN (?)"
      session[:conditions] << session[:params_member_ids]
    end
    unless session[:params_status_ids].blank?
      session[:conditions][0] += " AND issues.status_id IN (?)"
      session[:conditions] << session[:params_status_ids]
    end
    unless session[:params_custom_values].blank? || @custom_field.blank?
      session[:conditions][0] += " AND custom_values.value IN (?)"
      session[:conditions] << session[:params_custom_values]
      session[:conditions][0] += " AND custom_values.custom_field_id = ?"
      session[:conditions] << @custom_field.id
    end
    
    
    issue_no_position = Issue.where(:status_id => @board_columns.first[:status_ids])
    unless @use_version_for_sprint
      issue_no_position = issue_no_position.eager_load(:custom_values, {
          :project => :issue_custom_fields})
      issue_no_position = issue_no_position.where(:custom_values => {
          :custom_field_id => @custom_field.id})
    end
    issue_no_position = issue_no_position.where(session[:conditions]).order(:s2b_position)
    max_position_issue = issue_no_position.last.s2b_position.to_i + 1 unless issue_no_position.blank?
    issue_no_position = Issue.where(:s2b_position => nil)

    unless issue_no_position.blank?
      issue_no_position.each_with_index do |issue, index|
        issue.update_attribute(:s2b_position, max_position_issue + index)
      end
    end
    
    
    @board_columns.each do |board_column|
      issues = Issue.eager_load(:assigned_to, :tracker, :fixed_version, :status, :project).where(
          "status_id IN (?)", board_column[:status_ids])
      unless @use_version_for_sprint
        issues = issues.eager_load(:custom_values, {:project => :issue_custom_fields}).where(
            :custom_values => {:custom_field_id => @custom_field.id})         
      end
      issues = issues.where(session[:conditions])
      board_column.merge!({:issues => issues.order(:s2b_position)}) 
    end
  end



  # Reminds user to configure plugin if it hasn't already been configured. 
  def load_settings
    @plugin = Redmine::Plugin.find("scrum2b")
    @settings = Setting["plugin_#{@plugin.id}"]   
    board_columns = @settings["board_columns"]
    @board_columns = []
    if board_columns.blank?
      flash[:error] = "The system has not been setup to use Scrum2B Tool." + 
          " Please contact to Administrator or go to the Settings page of the plugin: " + 
          "<a href='/settings/plugin/scrum2b'>/settings/plugin/scrum2b</a> to config."
      redirect_to "/projects/#{@project.to_param}"
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
          @board_columns << {:name => board_column.last["name"], :status_ids => board_column.last["statuses"].keys}
        end
      end 
    end
    
    @use_version_for_sprint = @settings["use_version_for_sprint"] == "true"
    @show_progress_bars = @settings["show_progress_bars"] == "true"
    @custom_field = CustomField.find(@settings["custom_field_id"]) unless @use_version_for_sprint
    @current_sprint = @settings["current_sprint"] unless @use_version_for_sprint
    
    if @use_version_for_sprint
      if session[:params_custom_values] 
        session[:params_custom_values] = nil
        session[:conditions] = nil
      end
    else
      if session[:params_version_ids] 
        session[:params_version_ids] = nil
        session[:conditions] = nil
      end
    end
  end
  
  
end
