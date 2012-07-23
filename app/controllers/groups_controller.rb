# This class controls the Group model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class GroupsController < ApplicationController
  before_filter :load_employees, :only => [:index, :roster, :edit]
  before_filter :load_group, :only => [:edit, :update, :add_employee, :remove_employee, :destroy, :add_group_admin]
  before_filter :load_employee, :only => [:add_employee]
  
  
  
# View-related methods

  # List of all groups
  def index
    @group = Group.new
    @groups = Group.order(:name)
  end
  
  
  # Page for creating a new group
  def new
    authorize! :create, Group
    @group = Group.new
  end
  
  
  # Page for editing an existing group
  def edit
  end
  
  
  # Page containing the list of all employees assigned to a given group
  def roster
    @group = Group.find(params[:id])
  end
  
  
  
# Action-related methods
  
  # Creates a new group using the information entered on the "new" page
  def create
    authorize! :create, Group
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = "Group created!"
      redirect_to groups_path
      return
    end
    render :new
  end
  
  
  # Updates a group based on the information endered on the "edit" page
  def update
    @group.update_attributes(params[:group])
    flash[:notice] = "Group updated!"
    redirect_to groups_path 
  end
  
  
  # Adds the employee selected on the "roster" page to the given group
  def add_employee
    @group.employees << @employee
    flash[:notice] = "Employee added to group!"
    redirect_to roster_group_path(@group.id)
  end


  # Removes the employee selected on the "roster" page from the given group
  def remove_employee
    @employee = Employee.find(params[:employee])
    @group.employees.delete(@employee)
    flash[:notice] = "Employee removed from group!"
    redirect_to roster_group_path(@group.id)
  end
  
  
  # Populates the employee dropdown list on the "employee/home" page based on the group selected
  def employees
    if params[:group][:id] == "0"
      @employees = Employee.all
    else 
      @group = Group.find(params[:group][:id])
      @employees = @group.employees
    end
    render :layout => false
  end
  
  
  # Makes the selected individual an administrator for the current group
  def add_group_admin
    temp = @group.employee_groups.find_by_employee_id(params[:employee])
    temp.group_admin = true
    temp.save
    flash[:notice] = Employee.find(params[:employee]).full_name + " is now a group admin"
    redirect_to roster_group_path(@group.id)
  end
  
  
  # Casts the selected group into an unfathomable abyss of destruction
  def destroy
    authorize! :destroy, Group
    @group.destroy 
    flash[:notice] = "Group deleted!"
    redirect_to groups_path 
  end
  
  
  
# Loading methods

  private
    # Loads all employees
    def load_employees
      @employees = Employee.order(:name)
    end
  
  
    # Loads a group based on given parameters
    def load_group
      @group = Group.find(params[:id])
      authorize! :update, @group
    end
    
    
    # Loads an employee based on given parameters
    def load_employee
      @employee = Employee.find(params[:employee][:id])
    end
end