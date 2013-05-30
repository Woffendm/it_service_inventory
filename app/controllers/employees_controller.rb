# This class controls the Employee model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright: 

class EmployeesController < ApplicationController
  before_filter :authorize_creation,        :only => [:ldap_create, :search_ldap_view]
  before_filter :load_employee,             :only => [:destroy, :toggle_active, :update]
  before_filter :load_active_years,         :only => [:edit, :update]
  before_filter :load_all_years,            :only => [:show]
  before_filter :load_associations,         :only => [:edit, :show, :update]
  before_filter :load_available_associations, :only => [:edit, :update]
  before_filter :load_fte_hours_per_week,   :only => [:edit, :show, :update]
  before_filter :load_possible_allocations, :only => [:edit, :update]
  before_filter :authorize_update,          :only => [:edit, :update]
  skip_before_filter :remind_user_to_set_allocations, :only => [:edit, :update, :update_settings,
                                                                :user_settings]



# View-related methods

  # Page for editing an existing employee
  def edit
  end


  # Starts out as a list of all employees, but can be restricted by a search
  def index
    @year = @current_fiscal_year
    @groups = Group.order(:name)
    @services = Service.order(:name)
    @employees = filter_employees(params[:search])
    @employees = sort_results(params, @employees)
    @employees = @employees.paginate(:page => params[:page], 
                                     :per_page => session[:results_per_page])
  end


  # Page for searching the OSU directory for new employees
  def search_ldap_view
    @data = nil # This is here to prevent an error on the ldap_search_results partial
  end


  # Page for viewing an existing employee
  def show
    @total_services = @service_allocations.length
    @total_products = @product_allocations.length
    @total_service_allocation = @employee.get_total_service_allocation(@year, @allocation_precision)
    @total_product_allocation = @employee.get_total_product_allocation(@year, @allocation_precision)
  end


  # Page where a user can change some prefrences, such as language. 
  def user_settings
  end




# Action-related methods


  # Obliterates selected employee with the mighty hammer of Thor and scatters their data like dust  
  # to a thousand winds. (Removes employee and all associations)
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
  
  
  # Sets the specified employee's 'active' field to false. Inactive no longer appear in lists for
  # creating new associations, but all their existing associations are preserved.
  def toggle_active
    referring_page = request.referer
    authorize! :destroy, @employee
    if @employee.active
      @employee.active = false
      flash[:notice] = t(:employee) + "Deactivated"
    else
      @employee.active = true
      flash[:notice] = t(:employee) + "Activated"
    end
    @employee.save
    unless referring_page.blank?
      redirect_to referring_page
    else
      redirect_to pages_home_path
    end
  end


  # Imports an employee from the OSU LDAP and saves them to the application
  def ldap_create
    new_employee=Employee.new
    new_employee.name_last = params[:name_last]
    new_employee.name_first = params[:name_first]
    new_employee.name_MI = params[:name_MI]
    new_employee.osu_id = params[:osu_id]
    new_employee.osu_username = params[:osu_username]
    new_employee.email = params[:email].downcase unless params[:email].blank?
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
    # If a new service and allocation were sent with the params, adds them to the employee
    if params[:employee_products]
      unless (params[:employee_products][:product_id].blank?) ||
             (params[:employee_products][:fiscal_year_id].blank?)
        new_employee_product = @employee.employee_products.new(params[:employee_products])
        unless new_employee_product.save
          flash[:error] = t(:product) + t(:add) + t(:error)
          render :edit
          return
        end
      end
    end
    # Calculates the total allocation passed in params.
    if params["employee"] && params[:employee]["employee_allocations_attributes"]
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


    # Filters the employees displayed on the index page based on paramaters provided
    def filter_employees(search)
      return Employee.where(true) if search.blank?
      @group = search[:group]
      @service = search[:service]
      @name = search[:name]
      @active = search[:active]
      search_array = []
      if @name.blank?
        search_string = "true"
      else
        # Seperates '@name' into the first and last names, in array form. It does not assume that
        # the first name is entered first; therefore, each string is treated as potentially being 
        # either the first or last name.
        array_of_strings_to_search_for = @name.split(" ")
        # Searches for the first name (the first index)
        search_array << ("name_last LIKE '%#{array_of_strings_to_search_for[0]}%'")
        search_array << ("name_first LIKE '%#{array_of_strings_to_search_for[0]}%'")
        # Searches for the last name if present (the second index)
        if array_of_strings_to_search_for.length > 1
          search_array << ("name_last LIKE '%#{array_of_strings_to_search_for[1]}%'")
          search_array << ("name_first LIKE '%#{array_of_strings_to_search_for[1]}%'")
        end
        search_string = search_array.join(" OR ")
      end
      @employees = Employee.where(search_string)
      @employees = @employees.where("employees.active = " + @active) unless @active.blank?
      @employees = @employees.joins(:groups).where("groups.id" => @group).uniq unless @group.blank?
      @employees = @employees.joins(:services).where("services.id" => @service).uniq unless @service.blank?
      return @employees
    end
    

    # Loads the application setting fte_hours_per_week
    def load_fte_hours_per_week
      @fte_hours_per_week = AppSetting.get_fte_hours_per_week
    end


    # Loads all assigned associations for the employee in the given year. 
    def load_associations
      @employee = Employee.find(params[:id])
      @employee_groups = @employee.employee_groups.joins(:group).includes(:group).order("name")
      @service_allocations = @employee.employee_allocations.joins(:service).where(
          :fiscal_year_id => @year.id).includes(:service).order("name")
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
      @possible_allocations = EmployeeAllocation.possible_allocations(@allocation_precision)
    end


    # Loads all active years. Loads the last selected year if it is active
    def load_active_years
      @active_years = FiscalYear.active_fiscal_years
      @year = FiscalYear.find_by_year(cookies[:year])
      if @year.blank? || !@year.active
         flash[:message] = "Selected year #{@year.year} inactive. Year changed to #{@current_fiscal_year.year}." if @year
        @year = @current_fiscal_year
      end
    end
    
    
    # Loads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      @year = FiscalYear.find_by_year(cookies[:year])
      @year = @current_fiscal_year if @year.blank?
    end
end