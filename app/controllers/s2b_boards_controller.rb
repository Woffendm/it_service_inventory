class S2bBoardsController < S2bController
  before_filter :build_board_columns
  before_filter :find_issue,  :except =>  [:index, :create, :filter_issues_onboard]
  before_filter :load_filter_and_association_options, :only =>  [:index, :filter_issues_onboard,
      :update, :create, :edit] 
 
 
 
  def edit
    @issue = Issue.find(params[:issue_id])
    return if @issue.blank? 
    edit = render_to_string(:partial => "/s2b_boards/form_edit", :locals => {:issue => @issue, 
        :members => @members, :priorities => @priorities, :sprints => @sprints})
    render :json => {:result => "success", :content => edit}
  end
 
 
 
  def index
    @issue = Issue.new
    @blank_conditions = blank_conditions()
    if @sprint_use_default
      if @blank_conditions || session[:params_project_ids].blank?
        if @project.blank?
          unless @projects.blank?
            session[:params_project_ids] = @projects.first.id.to_s.to_a
            flash[:notice] = l(:notice_project_changed_to) + "#{@projects.first.name}"
          end
        else
          session[:params_project_ids] = @project.id.to_s.to_a
          flash[:notice] = l(:notice_project_changed_to) + "#{@project.name}"
        end
      end
    else
      if @blank_conditions
        session[:params_sprint_custom_values] = @current_sprint.to_s.to_a
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
    
    unless params[:assignee_custom_value].blank?
      cfv = @issue.get_custom_field_value(@assignee_custom_field)
      cfv.value = params[:assignee_custom_value] unless cfv.blank?
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
    unless @sprint_use_default && @priority_use_default && @assignee_use_default
      @sorted_issues = @sorted_issues.joins(:custom_values)
    end
    @sorted_issues = apply_conditions(@sorted_issues).order(:s2b_position)
    @issue = Issue.new(:subject => params[:subject], :description => params[:description],
        :tracker_id => params[:tracker], :project_id => params[:project], 
        :status_id => params[:status], :assigned_to_id => params[:assignee],
        :priority_id => params[:priority], :fixed_version_id => params[:version], 
        :start_date => params[:date_start], :due_date => params[:date_end], 
        :estimated_hours => params[:time], :author_id => User.current.id,
        :done_ratio => 0, :is_private => false, :lock_version => 0, :s2b_position => 1)
    @issue.valid?
    
    unless params[:sprint_custom_value].blank?
      errors = @sprint_custom_field.validate_field_value(params[:sprint_custom_value]).first
      @issue.errors.add :base, "#{@sprint_custom_field.name} #{errors}" unless errors.blank? 
    end
    
    unless params[:priority_custom_value].blank?
      errors = @priority_custom_field.validate_field_value(params[:priority_custom_value]).first
      @issue.errors.add :base, "#{@priority_custom_field.name} #{errors}" unless errors.blank? 
    end
    
    unless params[:assignee_custom_value].blank?
      errors = @assignee_custom_field.validate_field_value(params[:assignee_custom_value]).first
      @issue.errors.add :base, "#{@assignee_custom_field.name} #{errors}" unless errors.blank? 
    end
      
    if @issue.errors.messages.blank? && @issue.save
      unless params[:sprint_custom_value].blank?
        cfv = @issue.get_custom_field_value(@sprint_custom_field)
        cfv.value = params[:sprint_custom_value] unless cfv.blank?
      end

      unless params[:priority_custom_value].blank?
        cfv = @issue.get_custom_field_value(@priority_custom_field)
        cfv.value = params[:priority_custom_value] unless cfv.blank?
      end
      
      unless params[:assignee_custom_value].blank?
        cfv = @issue.get_custom_field_value(@assignee_custom_field)
        cfv.value = params[:assignee_custom_value] unless cfv.blank?
      end
      
      position = @sorted_issues.first ? @sorted_issues.first.s2b_position.to_i - 1 : 1
      
      @issue.update_attribute(:s2b_position, position)
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
    @issue = Issue.new
    session[:params_project_ids] = params[:project_ids].to_s.split(",").to_a
    session[:params_status_ids] = params[:status_ids].to_s.split(",").to_a
    session[:params_member_ids] = params[:member_ids].to_s.split(",").to_a
    session[:params_version_ids] = params[:version_ids].to_s.split(",").to_a
    session[:params_sprint_custom_values] = params[:sprint_custom_values].to_s.split(",").to_a
    session[:params_assignee_custom_values] = params[:assignee_custom_values].to_s.split(",").to_a
    
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
  
  
  # Returns true if there are no filters currently applied.
  def blank_conditions
    return session[:params_project_ids].blank? && session[:params_status_ids].blank? &&
        session[:params_member_ids].blank? &&  session[:params_version_ids].blank? &&  
        session[:params_sprint_custom_values].blank? && 
        session[:params_assignee_custom_values].blank?
  end
  
  
  
  # Builds a hash representing the columns for the scrum board. After running, each column will 
  # have a name and list of issue status ids associated with it. The collection of columns is stored
  # in @board_columns. 
  def build_board_columns
    @board_columns = []
    @settings["board_columns"].each do |board_column|
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
  
  
  
  def create_journal
    @issue.init_journal(User.current)
  end
  


  def filter_issues    
    # Assigns positions to all issues without positions.
    issue_no_position = Issue.where(:s2b_position => nil)
    unless issue_no_position.blank?
      max_position_issue = Issue.where(:status_id => @board_columns.first[:status_ids])
      max_position_issue = apply_conditions(max_position_issue).maximum(:s2b_position).to_i + 1
      issue_no_position.each_with_index do |issue, index|
        issue.update_attribute(:s2b_position, max_position_issue + index)
      end
    end
    
    # Populates each column with issues
    @board_columns.each do |board_column|
      issues = Issue.where(:status_id => board_column[:status_ids])
      issues = apply_conditions(issues)
      issues = Issue.where(:id => issues.pluck("issues.id")).eager_load(
          :assigned_to, :tracker, :fixed_version, :status, :project, :custom_values).limit(100)
      board_column.merge!({:issues => issues.order(:s2b_position)}) 
    end
  end



  def find_issue
    @issue = Issue.find(params[:issue_id])
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
    @issues_in_column = apply_conditions(@issues_in_column).order(:s2b_position)
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
  
  
  
  def validate_issue(issue)
    issue.valid?
    issue.custom_field_values.each do |cfv|
      cfv.validate_value
    end
    return issue.errors.messages.blank?
  end
  
end
