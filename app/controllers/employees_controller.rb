# This class controls the Employee model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright: 

class EmployeesController < ApplicationController
  before_filter :authorize_creation,        :only => [:ldap_create, :search_ldap_view]
  before_filter :load_employee,             :only => [:destroy, :update]
  before_filter :authorize_update,          :only => [:edit, :update]
  before_filter :load_active_years,         :only => [:edit, :update]
  before_filter :load_all_years,            :only => [:show]
  before_filter :load_associations,         :only => [:edit, :show, :update]
  before_filter :load_available_associations, :only => [:edit, :update]
  before_filter :load_allocation_precision, :only => [:edit, :show, :update]
  before_filter :load_possible_allocations, :only => [:edit, :update]
  skip_before_filter :remind_user_to_set_allocations, :only => [:edit, :update, :update_settings,
                                                                :user_settings]



# View-related methods

  # Page for editing an existing employee
  def edit
  end


  # Starts out as a list of all employees, but can be restricted by a search
  def index
    if params[:name_to_search_for]
      array_of_strings_to_search_for = params[:name_to_search_for].split(" ")
      conditions = []
      conditions << ("name_last LIKE '%#{array_of_strings_to_search_for[0]}%'")
      conditions << ("name_first LIKE '%#{array_of_strings_to_search_for[0]}%'")
      conditions << ("employee_allocations.fiscal_year_id = #{@year.id}") 
      conditions << ("employee_products.fiscal_year_id = #{@year.id}") 
      if array_of_strings_to_search_for.length > 1
        conditions << ("name_last LIKE '%#{array_of_strings_to_search_for[1]}%'")
        conditions << ("name_first LIKE '%#{array_of_strings_to_search_for[1]}%'")
      end
      @employees = Employee.where(conditions.join(" OR ")).order(:name_last, :name_first)
    else
      @employees = Employee.includes(:groups, :employee_allocations => [:service],
          :employee_products => [:product]).where("employee_allocations.fiscal_year_id = ? OR
          employee_products.fiscal_year_id = ?", @current_fiscal_year.id,
          @current_fiscal_year.id).order(:name_last, :name_first)
    end
    @employees = @employees.paginate(:page => params[:page], 
                                     :per_page => session[:results_per_page])
  end


  # Page for searching the OSU directory for new employees
  def search_ldap_view
    @data = nil # This is here to prevent an error on the ldap_search_results partial
  end


  # Page for viewing an existing employee
  def show
  end


  # Page where a user can change some prefrences, such as language. 
  def user_settings
  end




# Action-related methods


  # Obliterates selected employee with the mighty hammer of Thor and scatters their data like dust  
  # to a thousand winds
  def destroy
    authorize! :destroy, @employee
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


  # Updates an employee based on info entered on the "edit" page.
  def update
    new_total_allocation = 0.0
    # If a new group was sent with the params, adds it to the employee's list of groups
    if params[:employee_group]
      unless params[:employee_group][:group_id].blank?
        Group.find(params[:employee_group][:group_id]).add_employee_to_group(@employee)
      end
    end
    # If a new service and allocation were sent with the params, adds them to the employee
    if params[:employee_allocations]
      unless (params[:employee_allocations][:service_id].blank?) ||
             (params[:employee_allocations][:allocation].blank?) ||
             (params[:employee_allocations][:fiscal_year_id].blank?)
        new_employee_allocation = @employee.employee_allocations.new(params[:employee_allocations])
        new_employee_allocation.save
        new_total_allocation += new_employee_allocation.allocation
      end
    end
    # Calculates the total allocation passed in params.
    if params["employee"]["employee_allocations_attributes"]
      params["employee"]["employee_allocations_attributes"].to_a.each do |new_allocation|
        if new_allocation.last["_destroy"].to_f != 1
          new_total_allocation += new_allocation.last["allocation"].to_f
        end
      end
    end
    # Validates that the total allocation passed in params does not exceed 1FTE. It is only possible
    # to over-allocate a user if javascript is disabled.
    if (new_total_allocation <= 1) && (@employee.update_attributes(params[:employee]))        
      flash[:notice] = t(:employee) + t(:updated)      
      redirect_to edit_employee_path(@employee.id)
      return
    end
    flash[:error] = t(:over_allocated)
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


  # Updates a user's preferred setting based on their selections from the "User Settings" page
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
    
    
    # Ensures that the user is authorized to update the employee
    def authorize_update
      authorize! :update, @employee
    end


    # Loads the application settings fte_hours_per_week and allocation_precision
    def load_allocation_precision
      @fte_hours_per_week = AppSetting.get_fte_hours_per_week
      @allocation_precision = AppSetting.get_allocation_precision
    end


    # Loads all assigned associations for the employee in the given year. 
    def load_associations
      @employee = Employee.find(params[:id])
      @employee_groups = @employee.employee_groups.joins(:group).includes(:group).order("name")
      @service_allocations = @employee.employee_allocations.joins(:service).where(
          :fiscal_year_id => @year.id). includes(:service).order("name")
      @product_allocations = @employee.employee_products.joins(:product).where(
          :fiscal_year_id => @year.id).includes(:product).order("name")
    end


    # Loads all unassigned associations for the employee in the given year. 
    def load_available_associations
      @available_groups = @employee.get_available_groups
      @available_services = @employee.get_available_services(@year)
      @available_products = @employee.get_available_products(@year)
    end


    # Loads an employee based off parameters given and ensures that user is authorized to edit them
    def load_employee
      @employee = Employee.find(params[:id])
    end


    # Loads possible allocations
    def load_possible_allocations
      @possible_allocations = EmployeeAllocation.possible_allocations
    end


    # Loads all active years. Loads the last selected year if it is active
    def load_active_years
      @active_years = FiscalYear.active_fiscal_years
      if cookies[:year].blank? || !(@year = FiscalYear.find_by_year(cookies[:year])).active
        @year = @current_fiscal_year
      end
    end
    
    
    # CLoads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      if cookies[:year].blank?
        @year = @current_fiscal_year
      else
        @year = FiscalYear.find_by_year(cookies[:year])
      end
    end
end