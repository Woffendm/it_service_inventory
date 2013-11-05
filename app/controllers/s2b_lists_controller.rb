class S2bListsController < S2bController
  before_filter :load_filter_and_association_options



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
  
  
  def filter_issues
    # Determines whether to bother calculating issues without sprints
    @sorted_issues = []
    if @sprint_use_default
      if session[:params_version_ids].blank?
        versions = Version.where(:project_id => session[:params_project_ids]).order("created_on")
      else
        versions = Version.where(:id => session[:params_version_ids]).order("created_on")
      end
      
      # Finds all unfinished issues for each version of the project.
      versions.each do |version|
        issues = Issue.eager_load(:assigned_to, :status, :fixed_version, :priority, :custom_values)
        issues = issues.where(:fixed_version_id => version.id, :issue_statuses => 
            {:is_closed => false})
        issues = apply_conditions(issues)        
        @sorted_issues << {:name => version.name, :issues => issues.order(
            "status_id, s2b_position")}
      end
    else
      if session[:params_sprint_custom_values].blank?
        custom_values = @sprint_custom_field.possible_values
      else
        custom_values = session[:params_sprint_custom_values].to_a
      end
      
      # Finds all unfinished issues for each possible value in the custom field used for sprint
      custom_values.each do |cv|  
        issues = Issue.joins(:status).where(:issue_statuses => {:is_closed => false})
        issues = issues.joins("INNER JOIN custom_values cv0 ON issues.id = cv0.customized_id")
        issues = issues.where("cv0.custom_field_id = ? AND cv0.value = ?", 
            @sprint_custom_field.id, cv)
        issues = apply_conditions(issues)
        issues = issues.eager_load(:assigned_to, :status, :priority, :custom_values, :project)
        issues = issues.order("status_id, projects.name, s2b_position")
        @sorted_issues << {:name => cv, :issues => issues}
      end
    end
    
    filter_backlogs()
  end
  
  
  
  def filter_backlogs
    if session[:params_version_ids].blank? && session[:params_sprint_custom_values].blank?
      @issue_backlogs = Issue.joins(:status)
      if @sprint_use_default
        @issue_backlogs = @issue_backlogs.where(:fixed_version_id => nil)
      else
        @issue_backlogs = @issue_backlogs.joins(:custom_values) 
        issue_ids_with_custom_field = Issue.joins(:custom_values, :status).where(
            :issue_statuses => {:is_closed => false}).where(
            "(custom_values.custom_field_id = ? AND custom_values.value IS NOT NULL AND custom_values.value != '')", @sprint_custom_field.id)
        issue_ids_with_custom_field =
            apply_conditions(issue_ids_with_custom_field).pluck("issues.id")
        issue_ids_with_custom_field = [-1] if issue_ids_with_custom_field.blank?
        @issue_backlogs = @issue_backlogs.where("issues.id NOT IN (?)", issue_ids_with_custom_field)
      end
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
