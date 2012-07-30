# This class controls the Group model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class GroupsController < ApplicationController
  before_filter :load_employees, :only => [:roster]
  before_filter :load_group, :only => [:edit, :update, :add_employee, :remove_employee, :destroy, :add_group_admin]
  before_filter :load_employee, :only => [:add_employee]
  
  
  
# View-related methods

  # Page for editing an existing group
  def edit
  end


  # List of all groups
  def index
    @group = Group.new
    @groups = Group.order(:name)
  end
  
  
  # Page containing the list of all employees assigned to a given group
  def roster
    @group = Group.find(params[:id])
    @paginated_employees = @group.employees.order(:name_last).paginate(:page => params[:page],
                          :per_page => session[:results_per_page])
  end
  
  
  
# Action-related methods
  
  # Adds the employee selected on the "roster" page to the given group
  def add_employee
    @group.employees << @employee
    flash[:notice] = "Employee added to group!"
    redirect_to roster_group_path(@group.id)
  end
  
  
  # Makes the selected individual an administrator for the current group
  def add_group_admin
    temp = @group.employee_groups.find_by_employee_id(params[:employee])
    temp.group_admin = true
    temp.save
    flash[:notice] = Employee.find(params[:employee]).full_name + " is now a group admin"
    redirect_to roster_group_path(@group.id)
  end
  
  
  # Creates a new group using the information entered on the "new" page
  def create
    authorize! :create, Group
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = "Group created!"
    else
      flash[:error] = "New group name cannot be blank"
    end
    redirect_to groups_path
  end
  
  
  # Casts the selected group into an unfathomable abyss of destruction
  def destroy
    authorize! :destroy, Group
    @group.destroy 
    flash[:notice] = "Group deleted!"
    redirect_to groups_path 
  end
  
  
  # Populates the employee dropdown list on the "employee/home" page based on the group selected
  def employees
    if params[:group][:id] == "0"
      @employees = Employee.order(:name_last)
    else 
      @group = Group.find(params[:group][:id])
      @employees = @group.employees.order(:name_last)
    end
    render :layout => false
  end
  
  
  # Removes the employee selected on the "roster" page from the given group
  def remove_employee
    @employee = Employee.find(params[:employee])
    @group.employees.delete(@employee)
    flash[:notice] = "Employee removed from group!"
    redirect_to roster_group_path(@group.id)
  end
  
  
  # Updates a group based on the information endered on the "edit" page
  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = "Group updated!"
      redirect_to groups_path 
      return
    end
    flash[:error] = "Group must have a name"
    redirect_to edit_group_path(@group.id) 
  end
  
  
  
# Loading methods

  private
    # Loads an employee based on given parameters
    def load_employee
      @employee = Employee.find(params[:employee][:id])
    end
  
  
    # Loads all employees
    def load_employees
      @employees = Employee.order(:name_last)
    end
  
  
    # Loads a group based on given parameters
    def load_group
      @group = Group.find(params[:id])
      authorize! :update, @group
    end
end
