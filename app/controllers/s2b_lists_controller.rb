class S2bListsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :load_settings 
  before_filter :check_before_list
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
  



  def index
    if cookies[:view_issue].blank? || cookies[:view_issue] == "board" && 
        params[:switch_screens].blank?
      redirect_to :controller => "s2b_boards", :action => "index", 
          :project_id => params[:project_id]
      return
    end
    
    if cookies[:params_project_ids].blank? && @sprint_use_default
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
    
    filter_issues
  end
  
  
  
  
  def filter_issues_onlist        
    cookies[:view_issue] = { :value => "list", :expires => 1.hour.from_now }
    cookies[:params_project_ids] = { :value => params[:project_ids].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }
    cookies[:params_status_ids] = { :value => params[:status_ids].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }
    cookies[:params_member_ids] = { :value => params[:member_ids].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }
    cookies[:params_version_ids] = { :value => params[:version_ids].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }
    cookies[:params_sprint_custom_values] = { 
        :value => params[:sprint_custom_values].to_s.split(",").to_a, 
        :expires => 1.hour.from_now }
    
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
    @has_permission = true if !User.current.anonymous? && @members.include?(User.current) || User.current.admin
  end
  
  
  
  def filter_issues
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
    
    @issue_backlogs = Issue.eager_load(:custom_values, :status, :assigned_to, :project, :priority)
    
    @sorted_issues = []
    if @sprint_use_default
      @issue_backlogs = @issue_backlogs.where(:fixed_version_id => nil)
      if cookies[:params_version_ids].blank?
        versions = Version.where(:project_id => cookies[:params_project_ids]).order("created_on")
      else
        versions = Version.where(:id => cookies[:params_version_ids]).order("created_on")
      end
      versions.each do |version|
        issues = Issue.eager_load(:assigned_to, :status, 
            :fixed_version, :priority).where(:fixed_version_id => version, 
            :issue_statuses => {:is_closed => false})
        issues = issues.where(session[:conditions])
        @sorted_issues << {:name => version.name, :issues => issues.order(
            "status_id, s2b_position")}
      end
    else
      @issue_backlogs = @issue_backlogs.eager_load(:custom_values, 
          {:project => :issue_custom_fields})
      issue_ids_with_custom_field = Issue.joins(:custom_values).where(
          "custom_values.value IS NOT NULL").where(:custom_values => 
          {:custom_field_id => @sprint_custom_field.id}).pluck("issues.id")
      issue_ids_with_custom_field = [-1] if issue_ids_with_custom_field.blank?
      @issue_backlogs = @issue_backlogs.where("issues.id NOT IN (?)", issue_ids_with_custom_field)
      if cookies[:params_sprint_custom_values].blank?
        custom_values = @sprint_custom_field.possible_values
      else
        custom_values = cookies[:params_sprint_custom_values].to_a
      end
      custom_values.each do |cv|
        issues =  Issue.eager_load(:assigned_to, :status, :fixed_version, :priority,
            :custom_values, {:project => :issue_custom_fields}).where(
            :custom_values => {:custom_field_id => @sprint_custom_field.id, :value => cv}, 
            :issue_statuses => {:is_closed => false})
        issues = issues.where(session[:conditions])
        @sorted_issues << {:name => cv, :issues => issues.order("status_id, projects.name,
            s2b_position")}
      end
    end
    
    @issue_backlogs = @issue_backlogs.where(session[:conditions])
    @issue_backlogs = @issue_backlogs.where("issue_statuses.is_closed IS NOT TRUE")
    @issue_backlogs = @issue_backlogs.order("projects.name, status_id, s2b_position")
    @sorted_issues << {:name => l(:label_version_no_sprint), :issues => @issue_backlogs}
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
  
  
  
  def validate_conditions
    session[:conditions] = nil unless cookies[:conditions_valid]
  end
  
  
end
