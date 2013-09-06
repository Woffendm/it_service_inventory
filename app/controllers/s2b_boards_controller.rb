class S2bBoardsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :load_settings
  before_filter :check_before_board, :only => [:index, :close_on_board, :filter_issues_onboard,
                                               :update, :create]
  
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
 
 
 
  def index
    if @use_version_for_sprints
      max_position_issue = @project.issues.maximum(:s2b_position).to_i + 1
      issue_no_position = @project.issues.where(:s2b_position => nil)
    else
      max_position_issue = Issue.where(:project_id => @projects.pluck("projects.id")).maximum(
          :s2b_position).to_i + 1
      issue_no_position = Issue.where(:project_id => @projects.pluck("projects.id"), :s2b_position => nil)
    end
    unless issue_no_position.blank?
      issue_no_position.each_with_index do |issue, index|
        issue.update_attribute(:s2b_position, max_position_issue + index)
      end
    end
    session[:view_issue] = "board"
    params[:custom_values] = @current_sprint
    filter_issues(params)
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
    @id_version  = params[:version_ids]
    @issue = Issue.find(params[:id_issue])
    @issue.update_attributes(
        :subject => params[:subject], 
        :assigned_to_id => params[:assignee],
        :estimated_hours => params[:time],
        :description => params[:description], 
        :start_date => params[:date_start], 
        :due_date => params[:date_end], 
        :tracker_id => params[:tracker]
    )
    if @issue.valid? 
      data  = render_to_string(:partial => "/s2b_boards/show_issue", 
                               :locals => {:issue => @issue})
      edit  = render_to_string(:partial => "/s2b_boards/form_new", 
                               :locals => {:issue => @issue, :trackers => @trackers, 
                               :member => @members,
                               :statuses => @statuses, :priorities => @priorities, :sprints => @sprints})
      render :json => {:result => "edit_success", :message => "Success to update the message",
                       :content => data, :edit_content => edit }
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages,
                       :content => data, :edit_content => edit }
    end
  end
  
  
  
  def create
    @sort_issue = Issue.where(:project_id => @projects.pluck("projects.id")).where(
        "status_id IN (?)", @board_columns.first[:status_ids])    
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
      @sort_issue.each do |issue|
        issue.update_attribute(:s2b_position, issue.s2b_position.to_i + 1)
      end
      data = render_to_string(:partial => "/s2b_boards/board_issue", :locals => {
          :issue => @issue, :trackers => @trackers, :members => @members,
          :statuses => @statuses, :priorities => @priorities, :sprints => @sprints})
      render :json => {:result => "create_success", :message => "Success to create the issue",
          :content => data, :id => @issue.id}
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages}
    end
  end
    
  
  def filter_issues_onboard
    filter_issues(params)
    
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_boards/screen_board", 
            :locals => { :projects => @projects, :trackers => @trackers,
            :priorities => @priorities, :members => @members, :issue => @issue, :statuses => @statuses,
            :sprints => @sprints, :board_columns => @board_columns })
      }
    end
  end
  
  
  
  private
  
  
  def find_project
    # @project variable must be set before calling the authorize filter
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id) unless project_id.blank?
  end
  
  
  
  def check_before_board
    @issue = Issue.new
    @priorities = IssuePriority.all
    @trackers = Tracker.all
    @statuses = IssueStatus.sorted
    if @use_version_for_sprint
      @projects = @project.order(:name)
      @members = @project.assignable_users
      @sprints = Version.where(project_id: [@project.id, @project.parent_id])
    else
      @projects = Project.joins(:issue_custom_fields).where(:custom_fields => 
          {:id => @custom_field.id}).order("projects.name")
      @members = User.where(:id => Member.where(:project_id => @projects.pluck("projects.id")
          ).pluck(:user_id).uniq).order(:firstname)
      @sprints = @custom_field.possible_values
    end
    @has_permission = true if !User.current.anonymous? && @members.include?(User.current) || User.current.admin
  end
  


  def filter_issues(params)
    session[:params_version_ids] = params[:version_ids].to_s.split(",").to_a
    session[:params_member_ids] = params[:member_ids].to_s.split(",").to_a
    session[:params_custom_values] = params[:custom_values].to_s.split(",").to_a
    session[:params_project_ids] = params[:project_ids].to_s.split(",").to_a
    session[:params_status_ids] = params[:status_ids].to_s.split(",").to_a
    
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
    unless session[:params_custom_values].blank?
      session[:conditions][0] += " AND custom_values.value IN (?)"
      session[:conditions] << session[:params_custom_values]
      session[:conditions][0] += " AND custom_values.custom_field_id = ?"
      session[:conditions] << @custom_field.id
    end
    
    
    @board_columns.each do |board_column|
      if @use_version_for_sprint
        issues = @project.issues.eager_load(:assigned_to, :tracker, :fixed_version).where(
            "status_id IN (?)", board_column[:status_ids])
      else
        issues = Issue.eager_load(:assigned_to, :tracker, :fixed_version, :status).where(
            "status_id IN (?)", board_column[:status_ids])
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
      session[:params_custom_values] = nil
    else
      session[:params_version_ids] = nil
    end
  end
  
  
end
