class S2bListsController < ApplicationController
  unloadable
  before_filter :find_project, :only => [:index, :change_sprint, :close_on_list, :sort,
                                         :filter_issues_onlist]
  before_filter :load_settings 
  before_filter :filter_issues_onlist, :only => [:index]
  skip_before_filter :verify_authenticity_token
  self.allow_forgery_protection = false
  



  def index
    @select_issue_options = SELECT_ISSUE_OPTIONS
    @list_versions_open = opened_versions_list
    @list_versions_closed = closed_versions_list 
    @id_member = @project.assignable_users.collect{|id_member| id_member.id}
    @list_versions = @project.versions.all
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
  
  
  
  def change_sprint
    array_id= Array.new
    array_id = params[:issue_id]
    int_array = array_id.split(',').collect(&:to_i)
    issues = @project.issues.where(:id => int_array)
    issues.each do |issue|
      issue.update_attribute(:fixed_version_id,params[:new_sprint])
    end
    filter_issues_onlist
  end
  
  
  
  def filter_issues_onlist
    @sort_versions = {}
      if session[:view_issue].nil? || session[:view_issue] == "board" && (params[:switch_screens] || "").blank?
        redirect_to :controller => "s2b_boards", :action => "index" ,:project_id =>  params[:project_id]
        return
      end
    session[:view_issue] = "list"
    session[:param_select_version]  = (params[:select_version] || "version_working")
    session[:param_select_issues] = params[:select_issue].to_i if params[:select_issue]
    
    if session[:param_select_issues] == SELECT_ISSUE_OPTIONS[:new]
      all_backlog_status = STATUS_IDS['status_no_start'].dup
    elsif session[:param_select_issues] == SELECT_ISSUE_OPTIONS[:completed] || session[:param_select_issues] == SELECT_ISSUE_OPTIONS[:my_completed]
      all_backlog_status = STATUS_IDS['status_completed'].dup
    elsif session[:param_select_issues] == SELECT_ISSUE_OPTIONS[:closed] 
      all_backlog_status = STATUS_IDS['status_closed'].dup
    elsif !session[:param_select_issues] || session[:param_select_issues] == SELECT_ISSUE_OPTIONS[:all_working]
      all_backlog_status = STATUS_IDS['status_no_start'].dup
      all_backlog_status.push(STATUS_IDS['status_inprogress'].dup)
      all_backlog_status.push(STATUS_IDS['status_completed'].dup)
    else 
      all_backlog_status = STATUS_IDS['status_no_start'].dup
      all_backlog_status.push(STATUS_IDS['status_inprogress'].dup)
      all_backlog_status.push(STATUS_IDS['status_completed'].dup)
      all_backlog_status.push(STATUS_IDS['status_closed'].dup)
    end
    @issues = Issue.where(status_id: all_backlog_status.to_a).order("status_id, s2b_position DESC")
    # Filter my issues 
    if session[:param_select_issues] == SELECT_ISSUE_OPTIONS[:my] || session[:param_select_issues] == SELECT_ISSUE_OPTIONS[:my_completed]
        @issues = @issues.where(:assigned_to_id => User.current.id)
    end
    if session[:param_select_version] && session[:param_select_version] == "all"
      versions = @project.versions.order("created_on")
    elsif session[:param_select_version] && session[:param_select_version] != "version_working" && session[:param_select_version] != "all"
      versions = Version.where(:id => session[:param_select_version]).order("created_on")
    else
      versions = @project.versions.where("status NOT IN (?)","closed").order("created_on")
    end
    versions.each do |version|
      @sort_versions[version] = @issues.where(fixed_version_id: version)
    end
    id_issues = @issues.collect{|id_issue| id_issue.id}
    @issue_backlogs = @project.issues.where(:fixed_version_id => nil).where("id IN (?)",id_issues).order("status_id, s2b_position")
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_lists/screen_list",:locals => {:sort_versions => @sort_versions,:issues_backlog => @issues_backlog})
      }
      format.html {}
    end
  end
  
  
  
  def close_on_list
    array_id= Array.new
    array_id = params[:issue_id]
    int_array = array_id.split(',').collect(&:to_i)
    issues = @project.issues.where(:id => int_array)
    issues.each do |issue|
      issue.update_attribute(:status_id,DEFAULT_STATUS_IDS['status_closed'])
    end
    filter_issues_onlist   
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
    else
      session[:params_select_version_onboard] = nil
    end
  end
  
  
end
