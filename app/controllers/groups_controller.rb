# This class controls the Group model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class GroupsController < ApplicationController
  before_filter :load_group,               :only => [:toggle_group_admin, :destroy, :edit,
                                                     :show, :update]  
  before_filter :load_all_years,           :only => [:show, :services, :edit]                                
  before_filter :load_portfolios,          :only => [:edit, :update]
  before_filter :load_possible_employees,  :only => [:edit, :update]
  before_filter :load_possible_portfolios, :only => [:edit, :update]
  before_filter :load_existing_employees,  :only => [:edit, :update]
  before_filter :load_services,            :only => [:show]
  before_filter :load_products,            :only => [:show]
  before_filter :load_employees_for_year,  :only => [:show]
  before_filter :authorize_update,         :only => [:edit, :update]
                                            
  
# View-related methods

  # Page for editing an existing group
  def edit
  end


  # List of all groups
  def index
    @new_group = Group.new
    @groups = filter_groups(params[:search])
    @groups = sort_results(params, @groups)
    @groups = @groups.paginate(:page => params[:page], :per_page => session[:results_per_page])
  end


  # Page for viewing an existing group
  def show
    @portfolios = Portfolio.includes(:product_groups => :product).where(:product_groups => {:group_id => @group.id}).includes(:products).order("portfolios.name", "products.name").uniq
    @total_product_allocation = @group.get_total_product_allocation(@year, @allocation_precision)
    @total_service_allocation = @group.get_total_service_allocation(@year, @allocation_precision)
  end
  
  
# Action-related methods

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
    unless params[:employee_group].blank? || params[:employee_group][:employee_id].blank?
      if @group.employee_groups.new(params[:employee_group]).save
        flash[:notice] = t(:employee) + t(:added)
      else
        flash[:error] = "Cannot add employee"
        render :edit
        return
      end
    end
    unless params[:new_product_groups].blank?
      params[:new_product_groups].to_a.each do |new_pg|
        new_pg = new_pg.last
        unless new_pg.blank? || new_pg["product_id"].blank?
          if @group.product_groups.new(new_pg).save
            flash[:notice] = "Product added."
          else
            flash[:error] = "Cannot add product"
            render :edit
            return
          end
        end
      end
    end
    unless params[:new_group_portfolio].blank? || params[:new_group_portfolio][:portfolio_id].blank?
      @group.portfolios << Portfolio.find(params[:new_group_portfolio][:portfolio_id])
      flash[:notice] = t(:portfolio) + t(:added)
    end
    unless params[:new_portfolio].blank? || params[:new_portfolio][:name].blank?
      new_portfolio = Portfolio.new(params[:new_portfolio])
      if new_portfolio.save
        @group.portfolios << new_portfolio
        flash[:notice] = t(:portfolio) + t(:created)
      else
        flash[:error] = "Portfolio already exists"
        render :edit
        return
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
      @search_array = ["true"]
      @search_array << "groups.name LIKE '%#{@name}%'" unless @name.blank? 
      @search_string = @search_array.join(" AND ")
      @groups = Group.where(@search_string)
      return @groups
    end
    
    
    # Loads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      @year = FiscalYear.find_by_year(cookies[:year])
      @year = @current_fiscal_year if @year.blank?
    end
    
    
    # Loads all employees for the given year
    def load_employees_for_year
      @employees = @group.employees.joins(:employee_allocations).where(
          "employee_allocations.fiscal_year_id = ?",  @year.id).uniq.includes(
          :employee_allocations).order(:last_name, :first_name).paginate(:page =>   
          params[:employees_page], :per_page => session[:results_per_page])
    end


    # Loads all employees
    def load_existing_employees
      @existing_employees = EmployeeGroup.joins(:employee).where(
            :group_id => @group.id).includes(:employee).order(
            :last_name, :first_name).paginate(:page =>   
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
      @portfolios = @group.portfolios.order(:name)
    end
    
    
    def load_possible_portfolios
      @possible_portfolios = Portfolio.order(:name) - @portfolios
    end
    
    
    # Loads all products allocated to the group for the given fiscal year.
    def load_products
      @employees = @group.employees unless @employees
      @products = @group.products.joins(:employee_products).where(
          :employee_products => {:fiscal_year_id => @year.id, 
          :employee_id => @employees.pluck("employees.id")}
          ).uniq.order(:name).paginate(:page => params[:products_page], 
          :per_page => session[:results_per_page])
    end
    
    
    # Loads all services allocated to employees of the group
    def load_services
      @services = @group.services(@year).paginate(:page =>   
            params[:services_page], :per_page => session[:results_per_page])
    end
end
