class S2bListsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :load_settings 
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
  



  def index
    filter_issues
    @statuses = IssueStatus.sorted.where(:is_closed => false)
    if @use_version_for_sprint
      @sprints = Version.where(project_id: [@project.id, @project.parent_id])
      @members = @project.assignable_users
    else
      @sprints = @custom_field.possible_values
      @projects = Project.joins(:issue_custom_fields).where(:custom_fields => 
          {:id => @custom_field.id}).order("projects.name")
      @members = User.where(:id => Member.where(:project_id => @projects.pluck("projects.id")
          ).pluck(:user_id).uniq).order(:firstname)
    end
    @has_permission = true if !User.current.anonymous? && @members.include?(User.current) || User.current.admin
  end
  
  
  
  def sort
    @issues_in_column = Issue.eager_load(:assigned_to, :tracker, :fixed_version, :status)
    unless @use_version_for_sprints
      @issues_in_column = @issues_in_column.eager_load(:custom_values, {
          :project => :issue_custom_fields})
      @issues_in_column = @issues_in_column.where(:custom_values => {:custom_field_id => @custom_field.id})
    end
    @issue = Issue.find(params[:issue_id])
    @status_ids = [-1]
    @board_columns.each do |board_column|
      @status_ids = board_column[:status_ids]
      break if @status_ids.index(@issue.status_id.to_s)
    end
    
    @issues_in_column = @issues_in_column.where(:status_id => @status_ids)
    @issues_in_column = @issues_in_column.where(session[:conditions]).order(:s2b_position)
    @max_position = @issues_in_column.last.s2b_position unless @issues_in_column.blank?
    
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
      @issues_in_column.each do |issue|
        issue.update_attribute(:s2b_position, issue.s2b_position + 1) unless issue.id == @issue.id
      end
      @issue.update_attribute(:s2b_position, 1)
    else 
      @issues_in_column = @issues_in_column.where("s2b_position >= ? ", @next_position)
      @issues_in_column.each do |issue|
        issue.update_attribute(:s2b_position,issue.s2b_position + 1) unless issue.id == @issue.id
      end
      @issue.update_attribute(:s2b_position, @next_position)
    end
    data  = render_to_string(:partial => "/s2b_boards/show_issue", :locals => {:issue => @issue})
    render :json => {:result => "sort_success", :message => "Successfully sorted issues",
           :content => data}
  end
  
  
  
  
  def filter_issues_onlist    
    if session[:view_issue].blank? || session[:view_issue] == "board" && 
        params[:switch_screens].blank?
      redirect_to :controller => "s2b_boards", :action => "index", 
          :project_id => params[:project_id]
      return
    end
    
    session[:view_issue] = "list"
    session[:params_project_ids] = params[:project_ids].to_s.split(",").to_a
    session[:params_status_ids] = params[:status_ids].to_s.split(",").to_a
    session[:params_member_ids] = params[:member_ids].to_s.split(",").to_a
    session[:params_version_ids] = params[:version_ids].to_s.split(",").to_a
    session[:params_custom_values] = params[:custom_values].to_s.split(",").to_a
    
    filter_issues
  end  
  
  
  
  
  
  private  
  
  def filter_issues
    project_ids = session[:params_project_ids]
    project_ids = Project.joins(:issue_custom_fields).where(:custom_fields => {:id => @custom_field.id}).pluck("projects.id") if project_ids.blank?
    
    @issue_backlogs = Issue.eager_load(:custom_values, :status, :assigned_to, :project)
    @issue_backlogs = @issue_backlogs.where(:project_id => project_ids)
    @issue_backlogs = @issue_backlogs.where(:status_id => session[:params_status_ids]) unless session[:params_status_ids].blank?
    @issue_backlogs = @issue_backlogs.where(:assigned_to_id => session[:params_member_ids]) unless session[:params_member_ids].blank?
    
    @sorted_issues = []
    if @use_version_for_sprint
      @issue_backlogs = @issue_backlogs.where(:fixed_version_id => nil)
      if session[:params_version_ids].blank?
        versions = @project.versions.order("created_on")
      else
        versions = @project.versions.where(:id => session[:params_version_ids]
            ).order("created_on")
      end
      versions.each do |version|
        issues = @project.issues.eager_load(:assigned_to, :status, :tracker, 
            :fixed_version,).where(:fixed_version_id => version, 
            :issue_statuses => {:is_closed => false})
        issues = issues.where(:status_id => session[:params_status_ids]) unless
            session[:params_status_ids].blank?
        issues = issues.where(:assigned_to_id => session[:params_member_ids]) unless
            session[:params_member_ids].blank?
        @sorted_issues << {:name => version.name, :issues => issues.order(
            "status_id, s2b_position")}
      end
    else
      issue_ids_with_custom_field = Issue.joins(:custom_values).where(
          :project_id => project_ids).where(
          "custom_values.custom_field_id = ? AND custom_values.value IS NOT NULL",
          @custom_field.id).pluck("issues.id")
      issue_ids_with_custom_field = [-1] if issue_ids_with_custom_field.blank?
      @issue_backlogs = @issue_backlogs.where("issues.id NOT IN (?)", issue_ids_with_custom_field)
      if session[:params_custom_values].blank?
        custom_values = @custom_field.possible_values
      else
        custom_values = session[:params_custom_values]
      end
      custom_values.each do |cv|
        issues =  Issue.eager_load(:assigned_to, :status, :tracker, :fixed_version,
            :custom_values, {:project => :issue_custom_fields}).where(
            :project_id => project_ids).where(
            :custom_values => {:custom_field_id => @custom_field.id, :value => cv}, 
            :issue_statuses => {:is_closed => false})
        issues = issues.where(:status_id => session[:params_status_ids]) unless
            session[:params_status_ids].blank?
        issues = issues.where(:assigned_to_id => session[:params_member_ids]) unless
            session[:params_member_ids].blank?
        @sorted_issues << {:name => cv, :issues => issues.order("status_id, projects.name,
            s2b_position")}
      end
    end
    
    @issue_backlogs = @issue_backlogs.where("issue_statuses.is_closed IS NOT TRUE")
    @issue_backlogs = @issue_backlogs.order("status_id, projects.name, s2b_position")
    
    @sorted_issues << {:name => l(:label_version_no_sprint), :issues => @issue_backlogs}
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_lists/screen_list", 
            :locals => {:sorted_issues => @sorted_issues})
      }
      format.html {}
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
