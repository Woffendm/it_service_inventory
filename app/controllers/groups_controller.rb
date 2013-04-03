# This class controls the Group model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class GroupsController < ApplicationController
  before_filter :load_group,      :only => [:add_employee, :toggle_group_admin, :destroy, :edit,
                                            :remove_employee, :show, :update]  
  before_filter :load_all_years,  :only => [:show, :services]                                
  before_filter :load_employee,   :only => [:add_employee]
  before_filter :load_portfolios, :only => [:show, :edit]
  before_filter :load_possible_employees,  :only => [:edit]
  before_filter :load_existing_employees,  :only => [:show, :edit]
  before_filter :load_services,            :only => [:show]
  before_filter :load_products,            :only => [:show]
  before_filter :authorize_update, :only => [:add_employee, :toggle_group_admin, :edit,
                                            :remove_employee, :update]
                                            
  
# View-related methods

  # Page for editing an existing group
  def edit
  end


  # List of all groups
  def index
    @group = Group.new
    @groups = filter_groups(params[:search])
    @groups = sort_results(params, @groups)
    @groups = @groups.paginate(:page => params[:page], :per_page => session[:results_per_page])
  end


  # Page for viewing an existing group
  def show
    @total_employees = @group.employees.length
    @total_products = @group.products.length
    @total_services = @group.services(@year).length
    @total_product_allocation = @group.get_total_product_allocation(@year)
    @total_service_allocation = @group.get_total_service_allocation(@year)
  end
  
  
# Action-related methods
  
  # Adds the employee selected on the "roster" page to the given group
  def add_employee
    @group.add_employee_to_group(@employee)
    flash[:notice] = t(:employee) + t(:added)
    redirect_to edit_group_path(@group.id)
  end
  
  
  # Gives / removes the selected employee administrative abilities for the group
  def toggle_group_admin
    employee_group = Employee.find(params[:employee]).employee_groups.find_by_group_id(params[:id])
    employee_group.update_attributes(:group_admin => !employee_group.group_admin)
    if employee_group.group_admin
      flash[:notice] = t(:admin) + t(:added)
    else
      flash[:notice] = t(:admin) + t(:removed)
    end
    redirect_to edit_group_path(@group.id)
  end
  
  
  # Creates a new group using the information entered on the "new" page
  def create
    authorize! :create, Group
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = t(:group) + t(:created)
    else
      flash[:error] = t(:group) + t(:needs_a_name)
    end
    redirect_to groups_path
  end


  # Casts the selected group into an unfathomable abyss of destruction
  def destroy
    authorize! :destroy, Group
    @group.destroy 
    flash[:notice] = t(:group) + t(:deleted)
    redirect_to groups_path 
  end


  # Removes the employee selected on the "roster" page from the given group
  def remove_employee
    @employee = Employee.find(params[:employee])
    @group.remove_employee_from_group(@employee)
    flash[:notice] = t(:employee) + t(:removed)
    redirect_to edit_group_path(@group.id)
  end


  # Populates the service dropdown list on the "pages/home" page based on the group selected
  def services
    @selected_service = params[:selected_service]
    if params[:group][:id] == "0"
      @services = Service.joins(:employees).uniq.order(:name)
    else 
      @group = Group.find(params[:group][:id])
      @services = @group.services(@year)
    end
    render :layout => false
  end


  # Updates a group based on the information endered on the "edit" page
  def update
    unless params[:employee_group].blank?
      if @group.employee_groups.new(params[:employee_group]).save
        flash[:notice] = t(:employee) + t(:added)
      end
    end
    unless params[:portfolio].blank? || params[:portfolio][:name].blank?
      if @group.portfolios.new(params[:portfolio]).save
        flash[:notice] = t(:portfolio) + t(:added)
      end
    end
    if @group.update_attributes(params[:group])
      flash[:notice] = t(:group) + t(:updated)
      redirect_to edit_group_path(@group.id) 
      return
    end
    flash[:error] = t(:group) + t(:needs_a_name)
    render :edit
  end



# Loading methods

  private
    # Ensures user is authorized to update the group
    def authorize_update
      authorize! :update, @group
    end
    
    
    # Filters the services displayed on the index page based on paramaters provided
    def filter_groups(search)
      return Group.where(true) if search.blank?
      @name = search[:name]
      @search_string = ""
      @search_array = ["true"]
      @search_array << "groups.name LIKE '%#{@name}%'" unless @name.blank? 
      @search_string = @search_array.join(" AND ")
      @groups = Group.where(@search_string)
      return @groups
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
    
    
    # Loads an employee based on given parameters
    def load_employee
      @employee = Employee.find(params[:employee][:id])
    end


    # Loads all employees
    def load_existing_employees
      @existing_employees = EmployeeGroup.joins(:employee).where(
            :group_id => @group.id).includes(:employee).order(
            :name_last, :name_first).paginate(:page =>   
            params[:employees_page], :per_page => session[:results_per_page])
    end


    # Loads all employees not assigned to the group
    def load_possible_employees
      @possible_employees = @group.get_available_employees
    end


    # Loads a group based on given parameters
    def load_group
      @group = Group.find(params[:id])
    end
    
    
    # Loads all portfolios associated with the given group
    def load_portfolios
      @portfolios = @group.portfolios.order(:name).includes(@products)
    end
    
    
    # Loads all products allocated to the group
    def load_products
      @products = @group.products.order(:name).paginate(:page =>   
            params[:products_page], :per_page => session[:results_per_page])
    end
    
    
    # Loads all services allocated to employees of the group
    def load_services
      @services = @group.services(@year).paginate(:page =>   
            params[:services_page], :per_page => session[:results_per_page])
    end
end
