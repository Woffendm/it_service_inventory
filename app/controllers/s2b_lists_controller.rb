class S2bListsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :load_settings 
  before_filter :validate_conditions
  before_filter :check_before_list
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
  



  def index
    if session[:params_project_ids].blank? && @sprint_use_default
      if @project.blank?
        session[:params_project_ids] = @projects.first.id.to_s.to_a
        flash[:notice] = l(:notice_project_changed_to) + "#{@projects.first.name}"
      else
        session[:params_project_ids] = @project.id.to_s.to_a
        flash[:notice] = l(:notice_project_changed_to) + "#{@project.name}"
      end
    end
    
    filter_issues
  end
  
  
  
  
  def filter_issues_onlist        
    session[:params_project_ids] = params[:project_ids].to_s.split(",").to_a
    session[:params_status_ids] = params[:status_ids].to_s.split(",").to_a
    session[:params_member_ids] = params[:member_ids].to_s.split(",").to_a
    session[:params_version_ids] = params[:version_ids].to_s.split(",").to_a
    session[:params_sprint_custom_values] = params[:sprint_custom_values].to_s.split(",").to_a
    session[:params_assignee_custom_values] = params[:assignee_custom_values].to_s.split(",").to_a
    
    filter_issues
    
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_lists/screen_list", 
            :locals => {:sorted_issues => @sorted_issues})
      }
    end
  end  
  
  
  
  
  
  private  
  
  def check_before_list
    @statuses = IssueStatus.sorted.where(:is_closed => false)
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
    unless @assignee_use_default || @assignee_custom_field.blank?
      @member_hash = {}
      @members.each do |member|
        @member_hash = @member_hash.merge({member.id.to_s => member.name})
      end
    end
    @has_permission = true if !User.current.anonymous? && @members.include?(User.current) || User.current.admin
  end
  
  
  
  def filter_issues
    # Sets conditions based on what user selects in filters
    conditions = ["true"]
    unless session[:params_version_ids].blank?
      conditions[0] += " AND issues.fixed_version_id IN (?)"
      conditions << session[:params_version_ids]
    end
    unless session[:params_project_ids].blank?
      conditions[0] += " AND issues.project_id IN (?)"
      conditions << session[:params_project_ids]
    end
    unless session[:params_member_ids].blank?
      conditions[0] += " AND issues.assigned_to_id IN (?)"
      conditions << session[:params_member_ids]
    end
    unless session[:params_status_ids].blank?
      conditions[0] += " AND issues.status_id IN (?)"
      conditions << session[:params_status_ids]
    end
    unless session[:params_sprint_custom_values].blank? || @sprint_custom_field.blank?
      conditions[0] += " AND (custom_values.value IN (?) AND custom_values.custom_field_id = ?)"
      conditions << session[:params_sprint_custom_values]
      conditions << @sprint_custom_field.id
    end
    unless session[:params_assignee_custom_values].blank? || @assignee_custom_field.blank?
      conditions[0] += " AND (custom_values.value IN (?) AND custom_values.custom_field_id = ?)"
      conditions << session[:params_assignee_custom_values]
      conditions << @assignee_custom_field.id
    end
    session[:conditions] = conditions
    cookies[:conditions_valid] = { :value => true, :expires => 1.day.from_now }
    
    # Determines whether to bother calculating issues without sprints
    @show_backlogs = true if session[:params_version_ids].blank? && session[:params_sprint_custom_values].blank?
    @issue_backlogs = Issue.joins(:status) if @show_backlogs
    
    @sorted_issues = []
    if @sprint_use_default
      @issue_backlogs = @issue_backlogs.where(:fixed_version_id => nil) if @show_backlogs
      if session[:params_version_ids].blank?
        versions = Version.where(:project_id => session[:params_project_ids]).order("created_on")
      else
        versions = Version.where(:id => session[:params_version_ids]).order("created_on")
      end
      
      # Finds all unfinished issues for each version of the project.
      versions.each do |version|
        issues = Issue.eager_load(:assigned_to, :status, 
            :fixed_version, :priority).where(:fixed_version_id => version, 
            :issue_statuses => {:is_closed => false})
        issues = issues.joins(:custom_values) unless session[:params_assignee_custom_values].blank?
        issues = issues.where(session[:conditions])
        @sorted_issues << {:name => version.name, :issues => issues.order(
            "status_id, s2b_position")}
      end
    else
      # Finds all unfinished issues not assigned to a custom field sprint
      if @show_backlogs
        @issue_backlogs = @issue_backlogs.joins(:custom_values) 
        issue_ids_with_custom_field = Issue.joins(:custom_values, :status).where(
            session[:conditions]).where(:issue_statuses => {:is_closed => false}).where(
            "(custom_values.custom_field_id = ? AND custom_values.value IS NOT NULL AND custom_values.value != '')",
             @sprint_custom_field.id).pluck("issues.id")
        issue_ids_with_custom_field = [-1] if issue_ids_with_custom_field.blank?
        @issue_backlogs = @issue_backlogs.where("issues.id NOT IN (?)", issue_ids_with_custom_field)
      end
      
      if session[:params_sprint_custom_values].blank?
        custom_values = @sprint_custom_field.possible_values
      else
        custom_values = session[:params_sprint_custom_values].to_a
      end
      
      # Finds all unfinished issues for each possible value in the custom field used for sprint
      custom_values.each do |cv|  
        issues = Issue.joins(:custom_values, :status).where(:custom_values => 
            {:custom_field_id => @sprint_custom_field.id, :value => cv}, 
            :issue_statuses => {:is_closed => false})
        issues = issues.where(session[:conditions])
        if issues.blank?
          @sorted_issues << {:name => cv, :issues => []}
        else
          issues = Issue.where(:id => issues.pluck("issues.id")).eager_load(
              :assigned_to, :status, :fixed_version, :priority, :custom_values, :project)
          issues =  issues.order("status_id, projects.name, s2b_position")
          @sorted_issues << {:name => cv, :issues => issues}
        end
      end
    end
    
    if @show_backlogs
      @issue_backlogs = @issue_backlogs.where(session[:conditions])
      @issue_backlogs = @issue_backlogs.where("issue_statuses.is_closed IS NOT TRUE")
      @issue_backlogs = Issue.where(:id => @issue_backlogs.pluck("issues.id"))
      @issue_backlogs = @issue_backlogs.eager_load(:custom_values, :status, :assigned_to, 
          :project, :priority)
      @issue_backlogs = @issue_backlogs.order("projects.name, status_id, s2b_position")
      @sorted_issues << {:name => l(:label_version_no_sprint), :issues => @issue_backlogs}
    end
  end
  
  
  
  def find_project
    # @project variable must be set before calling the authorize filter
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id) unless project_id.blank?
  end
  
  
  
  # Reminds user to configure plugin if it hasn't already been configured. 
  def load_settings
    @plugin = Redmine::Plugin.find("scrum2b")
    @settings = Setting["plugin_#{@plugin.id}"]   
    board_columns = @settings["board_columns"]
    sprint_settings = @settings["sprint"]
    priority_settings = @settings["priority"]
    assignee_settings = @settings["assignee"]
    @board_columns = []
    if board_columns.blank? || sprint_settings.blank? || priority_settings.blank?
      flash[:error] = "The system has not been setup to use Scrum2B Tool." + 
          " Please contact to Administrator or go to the " + 
          "<a href='#{plugin_settings_path(@plugin)}'>Settings</a> page of the plugin."
      if @project 
        redirect_to Rails.root
      else
        redirect_to projects_path
      end
      return
    else
      board_columns.each do |board_column|
        if board_column.last["statuses"].blank?
          flash[:error] = "The Scrum2B board column named '" + board_column.last['name'] + 
              "' has no associated statuses. Please contact an Administrator or go to the " +
              "<a href='#{plugin_settings_path(@plugin)}'>Settings</a> page of the plugin."
              
          redirect_to projects_path
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

    @assignee_use_default = assignee_settings["use_default"] == "true"
    @assignee_custom_field = CustomField.find(assignee_settings["custom_field_id"]) unless @assignee_use_default

    if @sprint_use_default
      unless session[:params_sprint_custom_values].blank?
        session[:params_sprint_custom_values] = nil
        cookies.delete :conditions_valid
      end
    else
      unless session[:params_version_ids].blank?
        session[:params_version_ids] = nil
        cookies.delete :conditions_valid
      end
    end
    
    if @assignee_use_default
      unless sessions[:params_assignee_custom_values].blank?
        csession[:params_assignee_custom_values] = nil
        cookies.delete :conditions_valid
      end
    else
      unless session[:params_member_ids].blank?
        session[:params_member_ids]
        cookies.delete :conditions_valid
      end
    end
  end
  
  
  
  def validate_conditions
    unless cookies[:conditions_valid]
      session[:conditions] = nil
      session[:params_project_ids] = nil
      session[:params_status_ids] = nil
      session[:params_member_ids] = nil
      session[:params_version_ids] = nil
      session[:params_sprint_custom_values] = nil
    end
  end
  
  
  
end
