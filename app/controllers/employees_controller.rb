# This class controls the Employee model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright: 

class EmployeesController < ApplicationController
  
  before_filter :load_employee, :only => [:update, :destroy, :edit, :add_service, :remove_service]
  before_filter :load_employees, :only => [:home, :edit, :index]
  before_filter :load_groups, :only => [:index, :new, :edit, :home, :populate_employee_results, :search_ldap]
  before_filter :authorize_creation, :only => [:new, :search_ldap_view, :create, :ldap_create]

    
# View-related methods

  # Page for editing an existing employee
  def edit
  end
  

  # Page used to rapidly search for an employee
  def home
    @employee = nil
  end
  
  
  # List of all employees
  def index
  end
  

  # Page for searching the OSU directory for new employees
  def search_ldap_view
    @data = nil
  end
  
  
  
  
# Action-related methods

  # Adds a new service and corresponding allocation to an employee based off info entered on the
  # "edit" page
  def add_service
    @employee_allocation = @employee.employee_allocations.new(params[:employee_allocation])
    if @employee_allocation.save
      flash[:notice] = "Service added to employee!"
      redirect_to edit_employee_path(@employee.id)
      return
    end
    flash[:error] = "The total allocation for a given employee cannot exceed 1. Either lower the new allocation or remove an existing service  from the employee."
    render :edit
  end
  
  
  # Creates a new employee using info entered on the "new" page
  def create
    @employee = Employee.new(params[:employee])
    if @employee.save
      redirect_to edit_employee_path(@employee.id)
      return
    end
    render :new
  end


  # Obliterates selected employee with the mighty hammer of Thor and scatters their data like dust  
  # to a thousand winds
  def destroy
    authorize! :destroy, Employee
    @employee.destroy 
    flash[:notice] = "Employee deleted!"
    redirect_to employees_path 
  end


  # Imports an employee from the OSU LDAP and saves them to the application
  def ldap_create
    new_employee=Employee.new
    new_employee.name_last = params[:name_last]
    new_employee.name_first = params[:name_first]
    new_employee.name_MI = params[:name_MI]
    new_employee.osu_id = params[:osu_id]
    new_employee.osu_username = params[:osu_username]
    new_employee.email = params[:email].downcase
    if new_employee.save
      flash[:notice] = "Employee added to application!"
    else
      flash[:error] = "Employee is already in the application."
    end
    render :search_ldap_view
  end


  # Searches the OSU directory for individuals with the last and first names provided
  def ldap_search_results
    @employee = Employee.new
    @data = RemoteEmployee.search(params[:last_name], params[:first_name])
    render :layout => false
  end


  # Populates the employee dropdown list on the "home" page based off the employee roster of the
  # selected group
  def populate_employee_results
    @employee = Employee.find(params[:employee][:id])
    render :layout => false
  end
  

  # Removes a service and corresponding allocation from an employee based off selection made on the
  # "edit" page
  def remove_service
    @employee_allocation = @employee.employee_allocations.find(params[:employee_allocation])
    @employee_allocation.delete
    @employee.save
    flash[:notice] = "Service removed from employee!"
    redirect_to edit_employee_path(@employee.id)
  end


  # Updates an employee based on info entered on the "edit" page
  def update
    if @employee.update_attributes(params[:employee])
      flash[:notice] = "Employee updated!"
      redirect_to edit_employee_path 
      return
    end
      render :edit
  end


  # Updates
  def update_all_employees
 RemoteEmployee.update_search(Employee.first.osu_username, Employee.first.osu_id).first.uid.first
  end  
  
# Loading methods

  private
    # Ensures that the user is authorized to create new employees
    def authorize_creation
      authorize! :create, Employee
    end
      
      
    # Loads an employee based off parameters given and ensures that user is authorized to edit them
    def load_employee
      @employee = Employee.find(params[:id])
      authorize! :update, @employee
    end
    
    
    # Loads all employees in alphabetical order
    def load_employees
      @employees = Employee.order(:name_last)
    end
    
    
    # Loads all groups and services alphabetically
    def load_groups
      @groups = Group.order(:name)
      @services = Service.order(:name)
    end
end