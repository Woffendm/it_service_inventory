# This class controls the Employee model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright: 

class EmployeesController < ApplicationController
  
  before_filter :load_employee, :only => [:update, :destroy, :edit, :add_service, :remove_service]
  before_filter :load_employees, :only => [:home, :edit, :index]
  before_filter :load_groups, :only => [:index, :new, :edit, :home, :populate_employee_results, :search_ldap]

    
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
  
  
  # Page for creating a new employee
  def new
    @employee = Employee.new
  end
  

  # Page for searching the OSU directory for new employees
  def search_ldap_view
    @data = nil
    @message = ""
  end
  
  
  
  
# Action-related methods

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
    @employee.destroy 
    redirect_to employees_path 
  end


  # Imports an employee from the OSU LDAP and saves them to the application
  def ldap_create
    @employee=Employee.new
    @employee.name = params[:name]
    @employee.osu_id = params[:osu_id]
    @employee.osu_username = params[:osu_username]
    @employee.email = params[:email]
    if @employee.save
      @message = "Employee added to application!"
    else
      @message = "Error: Employee is already in the application :("
    end
    render :search_ldap_view
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
    redirect_to edit_employee_path(@employee.id)
  end


  # Searches the OSU directory for individuals with the last and first names provided
  def search_ldap
    @employee = Employee.new
    @message = ""
    search = params[:last_name] 
    if params[:first_name] != ""
      search = search + ", " + params[:first_name]
    end
    @data = RemoteEmployee.search(search)
    render :search_ldap_view
  end


  # Updates an employee based on info entered on the "edit" page
  def update
    if @employee.update_attributes(params[:employee])
      redirect_to edit_employee_path 
      return
    end
      render :edit
  end



  
  
# Loading methods

  private
    # Loads an employee based off parameters given
    def load_employee
      @employee = Employee.find(params[:id])
    end
    
    
    # Loads all employees in alphabetical order
    def load_employees
      @employees = Employee.order(:name)
    end
    
    
    # Loads all groups and services alphabetically
    def load_groups
      @groups = Group.order(:name)
      @services = Service.order(:name)
    end
end