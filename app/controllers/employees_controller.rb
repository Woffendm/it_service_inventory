# This class controls the Employee model, views, and related actions
#
# Author:
#

class EmployeesController < ApplicationController
  
  before_filter :load_groups, :only => [:index, :new, :edit, :home, :populate_employee_results]
  before_filter :load_employee, :only => [:update, :destroy, :edit, :add_service, :remove_service]
  
  
  
# View-related methods

  # Page used to rapidly search for an employee
  def home
    @employees = Employee.all
    @employee = nil
  end
  
  
  # List of all employees
  def index
    @employees = Employee.all
  end
  
  
  # Page for creating a new employee
  def new
    @employee=Employee.new
  end
  
  
  # Page for editing an existing employee
  def edit
  end
  
  
  
# Action-related methods

  # Creates a new employee using info entered on the "new" page
  def create
    @employee=Employee.new(params[:employee])
    if @employee.save
      redirect_to edit_employee_path(@employee.id)
      return
    end
    render :new
  end


  # Updates an employee based on info entered on the "edit" page
  def update
    if @employee.update_attributes(params[:employee])
      redirect_to employees_path 
      return
    end
      render :edit
  end
  
  
  # Adds a new service and corresponding allocation to an employee based off info entered on the
  # "edit" page
  def add_service
    @employee_allocation = @employee.employee_allocations.new(params[:employee_allocation])
    if @employee_allocation.save
      redirect_to edit_employee_path(@employee.id)
      return
    end
    render :edit
  end


  # Removes a service and corresponding allocation from an employee based off selection made on the
  # "edit" page
  def remove_service
    @employee_allocation = @employee.employee_allocations.find(params[:employee_allocation])
    @employee_allocation.delete
    @employee.save
    redirect_to edit_employee_path(@employee.id)
  end
  
  
  # Populates the employee dropdown list on the "home" page based off the employee roster of the
  # selected group
  def populate_employee_results
    @employee = Employee.find(params[:employee][:id])
    render :layout => false
  end
  
  
  # Obliterates selected employee with the mighty hammer of Thor and scatters their data like dust  
  # to a thousand winds
  def destroy
    @employee.destroy 
    redirect_to employees_path 
  end
  
  
  
#Loading methods

  private
    #Loads all groups and services
    def load_groups
      @groups = Group.all
      @services = Service.all
    end
    
    
    #Loads an employee based off parameters given
    def load_employee
      @employee=Employee.find(params[:id])
    end
end
