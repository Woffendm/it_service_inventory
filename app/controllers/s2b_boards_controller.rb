class S2bBoardsController < ApplicationController
  unloadable
  before_filter :find_project, :only => [:index, :update, :update_status, :update_progress, :create,
                                         :close_on_board, :filter_issues_onboard,
                                         :opened_versions_list, :closed_versions_list]
  before_filter :load_settings
  before_filter :check_before_board, :only => [:index, :close_on_board, :filter_issues_onboard,
                                               :update, :create]
  skip_before_filter :verify_authenticity_token

  self.allow_forgery_protection = false
 
 
 
  def index
    @max_position_issue = @project.issues.maximum(:s2b_position).to_i + 1
    @issue_no_position = @project.issues.where(:s2b_position => nil)
    @issue_no_position.each do |issue|
      issue.update_attribute(:s2b_position, @max_position_issue)
      @max_position_issue += 1
    end
    session[:view_issue] = "board"
    
    if @use_version_for_sprint
      @sprints = Version.where(project_id: [@project.id, @project.parent_id])
    else
      @sprints = @custom_field.possible_values
    end
    
    @board_columns.each do |board_column|
      board_column.merge!({:issues => @project.issues.eager_load(:assigned_to, :tracker,
          :fixed_version, :custom_values, {:project => :issue_custom_fields}).where(
          "status_id IN (?)", board_column[:status_ids]).where(session[:conditions]).where(
          :custom_values => {:custom_field_id => @custom_field.id}).order(:s2b_position)}) 
    end
  end
  
  
  
  # Had to get rid of 'done ratio' stuff
  def update_status
    @issue = @project.issues.find(params[:issue_id])
    new_status = params[:status]
    return unless @issue && !new_status.blank?
    new_status = new_status.to_f.to_i
    new_status = IssueStatus.find(@board_columns[new_status][:status_ids].first)
    @issue.update_attributes(:done_ratio => new_status.default_done_ratio, 
        :status_id => new_status.id)
        
    
    if @issue.valid? 
      data  = render_to_string(:partial => "/s2b_boards/show_issue", 
                               :locals => {:issue => @issue})
      render :json => {:result => "update_success", :message => "Success to update the message",
                       :content => data}
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages,
                       :content => data}
    end
    
    # idk what this does. only done if was in "completed" column
    #  render :json => {:status => "completed", :done_ratio => 100 }
  end
  
  
  
  def update_progress
    @issue = @project.issues.find(params[:issue_id])
    @issue.update_attribute(:done_ratio, params[:done_ratio])
    render :json => {:result => "success", :new => "Success to update the progress",
                     :new_ratio => params[:done_ratio]}
  end
  
  
  
  # IDK if this should even stay here. Isn't the update status sufficient?
  def close_on_board
    array_id = params[:issue_id]
    @int_array = array_id.split(',').collect(&:to_i)
    @issues = @project.issues.where(:id => @int_array)
    @issues.each do |issues|
      issues.update_attribute(:status_id, DEFAULT_STATUS_IDS['status_closed'])
    end
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_boards/screen_board", 
            :locals => {:id_member => @id_member, :project => @project, :tracker => @tracker,
            :priority => @priority,:member => @member, :issue => @issue, :status => @status,
            :sprints => @sprints })
      }
    end
  end
  


  def update
    @id_version  = params[:select_version]
    @issue = @project.issues.find(params[:id_issue])
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
                               :locals => {:issue => @issue, :id_member => @id_member})
      edit  = render_to_string(:partial => "/s2b_boards/form_new", 
                               :locals => {:issue => @issue, :tracker => @tracker, 
                               :member => @member, :id_member => @id_member,
                               :status => @status, :priority => @priority, :sprint => @sprint})
      render :json => {:result => "edit_success", :message => "Success to update the message",
                       :content => data, :edit_content => edit }
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages,
                       :content => data, :edit_content => edit }
    end
  end
  
  
  
  def create
    r = params[:custom_value]
    @sort_issue = @project.issues.where("status_id IN (?)", @board_columns.first[:status_ids])    
    @issue = Issue.new(:subject => params[:subject], :description => params[:description],
        :tracker_id => params[:tracker], :project_id => params[:project_id], 
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
          :issue => @issue, :tracker => @tracker, :member => @member, :id_member => @id_member,
          :status => @status, :priority => @priority, :sprint => @sprint})
      render :json => {:result => "create_success", :message => "Success to create the issue",
          :content => data, :id => @issue.id}
    else
      render :json => {:result => "failure", :message => @issue.errors.full_messages}
    end
  end
  
  
  
  def filter_issues_onboard
    session[:params_select_version_onboard] = params[:select_version]
    session[:params_select_member] = params[:select_member]
    session[:params_custom_value] = params[:select_custom_value]
    session[:conditions] = ["true"]
    unless session[:params_select_version_onboard].blank? || session[:params_select_version_onboard] == "undefined"
      session[:conditions][0] += " AND fixed_version_id = ? "
      session[:conditions] << session[:params_select_version_onboard]
    end
    unless session[:params_select_member].blank?
      session[:conditions][0] += " AND assigned_to_id = ?"
      session[:conditions] << session[:params_select_member].to_i
    end
    unless session[:params_custom_value].blank? || session[:params_custom_value] == "undefined"
      session[:conditions][0] += " AND custom_values.value = ?"
      session[:conditions] << session[:params_custom_value].to_i
      session[:conditions][0] += " AND custom_values.custom_field_id = ?"
      session[:conditions] << @custom_field.id
    end
    
    @board_columns.each do |board_column|
      board_column.merge!({:issues => @project.issues.includes(:assigned_to, :tracker,
          :fixed_version, {:custom_values => :custom_field}, 
          {:project => :issue_custom_fields}).where(
          "status_id IN (?)", board_column[:status_ids]).where(session[:conditions]).order(
          :s2b_position)}) 
    end
    
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/s2b_boards/screen_board", 
            :locals => {:id_member => @id_member, :project => @project, :tracker => @tracker,
            :priority => @priority, :member => @member, :issue => @issue, :status => @status,
            :sprints => @sprints, :board_columns => @board_columns })
      }
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
  
  
  
  def check_before_board
    @issue = Issue.new
    @priority = IssuePriority.all
    @tracker = Tracker.all
    @status = IssueStatus.sorted
    if @use_version_for_sprint
      @sprints = @project.versions.where(:status => "open")
    else
      @sprints = @custom_field.possible_values
    end
    @project =  Project.find(params[:project_id])
    @member = @project.assignable_users
    @id_member = @member.collect{|id_member| id_member.id}    
    @has_permission = true if !User.current.anonymous? && @id_member.include?(User.current.id) || User.current.admin
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
