class S2bListsController < ApplicationController
  unloadable
  before_filter :find_project, :only => [:index, :change_sprint, :close_on_list, :sort,
                                         :filter_issues_onlist]
  before_filter :load_settings 
  before_filter :filter_issues_onlist, :only => [:index]
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
  



  def index
    @member = @project.assignable_users
    @id_member = @project.assignable_users.collect{|id_member| id_member.id}
    @issue_statuses = IssueStatus.sorted.where(:is_closed => false)
    if @use_version_for_sprint
      @sprints = Version.where(project_id: [@project.id, @project.parent_id])
    else
      @sprints = @custom_field.possible_values
    end
    @has_permission = true if !User.current.anonymous? && @id_member.include?(User.current.id) || User.current.admin
  end
  
  
  
  def sort
    @issue = @project.issues.find(params[:issue_id])
    @status_ids = [-1]
    @board_columns.each do |board_column|
      @status_ids = board_column[:status_ids]
      break if @status_ids.index(@issue.status_id.to_s)
    end
    @issues_in_column = @project.issues.where("status_id IN (?)", @status_ids).order(:s2b_position)
    @max_position = @issues_in_column.last.s2b_position
    
    if params[:id_next].to_i != 0
      next_issue = @project.issues.find(params[:id_next].to_i) 
      @next_position = next_issue.s2b_position
    end
    
    if params[:id_prev].to_i != 0
      prev_issue = @project.issues.find(params[:id_prev].to_i)
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
      @issues_in_column = @project.issues.where("status_id IN (?) AND s2b_position >= ? ", @status_ids, @next_position)
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
    session[:param_select_issue] = params[:select_issue]
    @issue_backlogs = @project.issues.eager_load(:custom_values, :status, :assigned_to)
    @issue_backlogs = @issue_backlogs.where(:status_id => session[:param_select_issue]) unless
        session[:param_select_issue].blank?
    
    @sorted_issues = []
    if @use_version_for_sprint
      session[:param_select_version]  = params[:select_version]
      @issue_backlogs = @issue_backlogs.where(:fixed_version_id => nil)
      if session[:param_select_version].blank?
        versions = @project.versions.order("created_on")
      else
        versions = @project.versions.where(:id => session[:param_select_version]
            ).order("created_on")
      end
      versions.each do |version|
        issues = @project.issues.eager_load(:assigned_to, :status, :tracker, 
            :fixed_version,).where(:fixed_version_id => version, 
            :issue_statuses => {:is_closed => false})
        issues = issues.where(:status_id => session[:param_select_issue]) unless
            session[:param_select_issue].blank?
        @sorted_issues << {:name => version.name, :issues => issues.order(:s2b_position)}
      end
    else
      session[:param_select_custom_value]  = params[:select_custom_value]
      issue_ids_with_custom_field = @project.issues.joins(:custom_values).where(
          "custom_values.custom_field_id = ? AND custom_values.value IS NOT NULL",
           @custom_field.id).pluck(:id)
      @issue_backlogs = @issue_backlogs.where("issues.id NOT IN (?)", issue_ids_with_custom_field)
      if session[:param_select_custom_value].blank?
        custom_values = @custom_field.possible_values
      else
        custom_values = [session[:param_select_custom_value]]
      end
      custom_values.each do |cv|
        issues =  @project.issues.eager_load(:assigned_to, :status, :tracker, :fixed_version,
            :custom_values, {:project => :issue_custom_fields}).where(
            :custom_values => {:custom_field_id => @custom_field.id, :value => cv}, 
            :issue_statuses => {:is_closed => false})
        issues = issues.where(:status_id => session[:param_select_issue]) unless
            session[:param_select_issue].blank?
        @sorted_issues << {:name => cv, :issues => issues.order(:s2b_position)}
      end
    end
    
    @issue_backlogs = @issue_backlogs.where("issue_statuses.is_closed IS NOT TRUE")
    @issue_backlogs = @issue_backlogs.order("status_id, s2b_position")
    
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_lists/screen_list", 
            :locals => {:sorted_issues => @sorted_issues, :issue_backlogs => @issue_backlogs})
      }
      format.html {}
    end
  end
  
  
  
  
  
  private
  
  
  def opened_versions_list
    find_project unless @project
    return Version.where(status:"open").where(project_id: [@project.id,@project.parent_id])
  end
  
  
  
  def closed_versions_list 
    find_project unless @project
    return Version.where(status:"closed").where(project_id: [@project.id,@project.parent_id])
  end
  
  
  
  def find_project
    # @project variable must be set before calling the authorize filter
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id)
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
    @custom_field = CustomField.find(@settings["custom_field_id"])
    
    if @use_version_for_sprint
      session[:params_custom_value] = nil
      session[:param_select_custom_value] = nil
    else
      session[:params_select_version_onboard] = nil
      session[:param_select_version] = nil
    end
  end
  
  
end
