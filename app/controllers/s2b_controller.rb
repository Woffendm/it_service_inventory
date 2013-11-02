class S2bController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :load_settings
  before_filter :validate_conditions  
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
 
  
  
  protected
  
  
  # Filters issues based on filter data stored in the session. Renews the validity of the session
  # filter.
  # Takes: ActiveRecord relation of issues (unfiltered)
  # Returns: ActiveRecord relation of issues (filtered)
  def apply_conditions(issues)
    unless session[:params_version_ids].blank?
      issues = issues.where("issues.fixed_version_id IN (?)", session[:params_version_ids])
    end
    
    unless session[:params_project_ids].blank?
      issues = issues.where("issues.project_id IN (?)", session[:params_project_ids])
    end
    
    unless session[:params_member_ids].blank?
      issues = issues.where("issues.assigned_to_id IN (?)", session[:params_member_ids])
    end
    
    unless session[:params_status_ids].blank?
      issues = issues.where("issues.status_id IN (?)", session[:params_status_ids])
    end
    
    unless session[:params_sprint_custom_values].blank? || @sprint_custom_field.blank?
      issues = issues.joins("INNER JOIN custom_values cv1 ON issues.id = cv1.customized_id")
      issues = issues.where("cv1.custom_field_id = ? AND cv1.value IN (?)", 
          @sprint_custom_field.id, session[:params_sprint_custom_values])
    end
    
    unless session[:params_assignee_custom_values].blank? || @assignee_custom_field.blank?
      issues = issues.joins("INNER JOIN custom_values cv2 ON issues.id = cv2.customized_id")
      issues = issues.where("cv2.custom_field_id = ? AND cv2.value IN (?)",
          @assignee_custom_field.id, session[:params_assignee_custom_values])
    end
    
    cookies[:conditions_valid] = { :value => true, :expires => 1.day.from_now }
    return issues
  end



  def find_project
    # @project variable must be set before calling the authorize filter
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id) unless project_id.blank?
    session[:params_project_ids] = @project.id.to_s.to_a unless @project.blank?
  end



  # Loads settings and builds board_columns hash. Reminds user to configure plugin if it hasn't 
  # already been configured. 
  # TODO: This should be two different methods. One for loading, another for building the hash.
  def load_settings
    @plugin = Redmine::Plugin.find("scrum2b")
    @settings = Setting["plugin_#{@plugin.id}"]   
    board_columns = @settings["board_columns"]
    sprint_settings = @settings["sprint"]
    priority_settings = @settings["priority"]
    assignee_settings = @settings["assignee"]
    @board_columns = []
    if board_columns.blank? || sprint_settings.blank? || priority_settings.blank? || assignee_settings.blank?
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
  end
  
  
  
  # Clears all filter data if either 1. the filter has expired OR 2. the filter contains information
  # not being used under current settings
  def validate_conditions
    if @sprint_use_default
      unless session[:params_sprint_custom_values].blank?
        cookies.delete :conditions_valid
      end
    else
      unless session[:params_version_ids].blank?
        cookies.delete :conditions_valid
      end
    end
    
    if @assignee_use_default
      unless session[:params_assignee_custom_values].blank?
        cookies.delete :conditions_valid
      end
    end
    
    unless cookies[:conditions_valid]
      session[:params_project_ids] = nil
      session[:params_status_ids] = nil
      session[:params_member_ids] = nil
      session[:params_version_ids] = nil
      session[:params_sprint_custom_values] = nil
      session[:params_assignee_custom_values] = nil
    end
  end
  
  
end
