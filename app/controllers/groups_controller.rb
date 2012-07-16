# This class controls the Group model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class GroupsController < ApplicationController
  before_filter :load_employees, :only => [:index, :roster, :edit]
  before_filter :load_group, :only => [:edit, :update, :add_employee, :remove_employee, :destroy, :roster]
  before_filter :load_employee, :only => [:add_employee]
  
  
  
# View-related methods

  # List of all groups
  def index
    @groups = Group.order(:name)
  end
  
  
  # Page for creating a new group
  def new
    @group = Group.new
  end
  
  
  # Page for editing an existing group
  def edit
  end
  
  
  # Page containing the list of all employees assigned to a given group
  def roster
  end
  
  
  
# Action-related methods
  
  # Creates a new group using the information entered on the "new" page
  def create
    @group = Group.new(params[:group])
    if @group.save
      redirect_to groups_path
      return
    end
    render :new
  end
  
  
  # Updates a group based on the information endered on the "edit" page
  def update
    @group.update_attributes(params[:group])
    redirect_to edit_group_path 
  end
  
  
  # Adds the employee selected on the "roster" page to the given group
  def add_employee
    @group.employees << @employee
    redirect_to roster_group_path(@group.id)
  end


  # Removes the employee selected on the "roster" page from the given group
  def remove_employee
    @employee = Employee.find(params[:employee])
    @group.employees.delete(@employee)
    redirect_to roster_group_path(@group.id)
  end
  
  
  # Populates the employee dropdown list on the "employee/home" page based on the group selected
  def employees
    if params[:group][:id].nil?
      @employees = Employee.all
    else 
      @group = Group.find(params[:group][:id])
      @employees = @group.employees
    end
    render :layout => false
  end
  
  
  # Casts the selected group into an unfathomable abyss of destruction
  def destroy
    @group.destroy 
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
    end
    
    # Loads an employee based on given parameters
    def load_employee
      @employee = Employee.find(params[:employee][:id])
    end
end
