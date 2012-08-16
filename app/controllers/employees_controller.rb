# This class controls the Employee model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright: 

class EmployeesController < ApplicationController

  before_filter :authorize_creation,   :only => [:create, :ldap_create, :search_ldap_view]
  before_filter :load_employee,        :only => [:destroy, :edit, :update]
  before_filter :load_groups_services, :only => [:edit, :update]


# View-related methods

  # Page for editing an existing employee
  def edit
  end


  # List of all employees
  def index
    @employees = Employee.order(:name_last, :name_first).paginate(:page => params[:page], 
                :per_page => session[:results_per_page])
  end


  # Page for searching the OSU directory for new employees
  def search_ldap_view
    @data = nil # This is here to prevent an error on the ldap_search_results partial
  end


  # Page where a user can change some prefrences, such as language. 
  def user_settings
  end




# Action-related methods


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
    if @employee != @current_user 
      @employee.destroy 
      flash[:notice] = t(:employee) + t(:deleted)
    else
      flash[:error] = t(:cannot_delete_self)
    end
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
      flash[:notice] = t(:employee) + t(:added)
    else
      flash[:error] = t(:already_in_application)
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
    if params[:employee][:id] == "0"
      @employee = nil
    else
      @employee = Employee.find(params[:employee][:id])
    end
    render :layout => false
  end


  # Updates an employee based on info entered on the "edit" page.
  def update
    # If a new group was sent with the params, adds it to the employee's list of groups
    if params[:employee_groups]
      unless params[:employee_groups][:group_id].blank?
        Group.find(params[:employee_groups][:group_id]).add_employee_to_group(@employee)
      end
    end
    # If a new service and allocation were sent with the params, adds them to the employee
    if params[:employee_allocations]
      unless (params[:employee_allocations][:service_id].blank?) &&
             (params[:employee_allocations][:allocation].blank?)
        new_employee_allocation = @employee.employee_allocations.new(params[:employee_allocations])
        new_employee_allocation.save
      end
    end
    if (@employee.update_attributes(params[:employee]))        
      flash[:notice] = t(:employee) + t(:updated)      
      redirect_to edit_employee_path(@employee.id)
      return
    end
    render :edit
  end


  # Searches OSU's ldap for all employees in the applicaiton by both their username and ids. Once 
  # found, updates the employee's name and email. 
  def update_all_employees_via_ldap
    authorize! :manage, Employee
    RemoteEmployee.update_all_employees
    flash[:notice] = t(:all_employees) + " " + t(:updated)
    redirect_to employees_path
  end


  # Updates an employee based on info entered on the "edit" page
  def update_settings
    @employee = Employee.find(@current_user.id)
    @employee.update_attributes(params[:employee])
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to user_settings_employee_path(@current_user.id)
  end




  # Updates the names and emails of all employees in the application based off the most recent
  # information provided in the OSU online directory
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


    # Loads all groups and services assigned to the current employee
    def load_groups_services
      @services = @employee.services.order(:name)
      @groups = @employee.groups.order(:name)
    end
end