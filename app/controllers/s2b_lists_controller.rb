class S2bListsController < S2bController
  before_filter :check_before_list



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
        issues = apply_conditions(issues)        
        @sorted_issues << {:name => version.name, :issues => issues.order(
            "status_id, s2b_position")}
      end
    else
      # Finds all unfinished issues not assigned to a custom field sprint
      if @show_backlogs
        @issue_backlogs = @issue_backlogs.joins(:custom_values) 
        issue_ids_with_custom_field = Issue.joins(:custom_values, :status).where(
            :issue_statuses => {:is_closed => false}).where(
            "(custom_values.custom_field_id = ? AND custom_values.value IS NOT NULL AND custom_values.value != '')", @sprint_custom_field.id)
        issue_ids_with_custom_field =
            apply_conditions(issue_ids_with_custom_field).pluck("issues.id")
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
        issues = apply_conditions(issues)
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
      @issue_backlogs = apply_conditions(@issue_backlogs)
      @issue_backlogs = @issue_backlogs.where("issue_statuses.is_closed IS NOT TRUE")
      @issue_backlogs = Issue.where(:id => @issue_backlogs.pluck("issues.id"))
      @issue_backlogs = @issue_backlogs.eager_load(:custom_values, :status, :assigned_to, 
          :project, :priority)
      @issue_backlogs = @issue_backlogs.order("projects.name, status_id, s2b_position")
      @sorted_issues << {:name => l(:label_version_no_sprint), :issues => @issue_backlogs}
    end
  end
  
  
end
