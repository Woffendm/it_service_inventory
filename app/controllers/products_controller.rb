# This class controls the Product model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class ProductsController < ApplicationController
  before_filter :load_product,                      :only => [:destroy, :edit, :show, :update]
  before_filter :load_active_years,                 :only => [:edit, :update]
  before_filter :load_all_years,                    :only => [:show]
  before_filter :load_associations,                 :only => [:edit, :show, :update]
  before_filter :load_available_associations,       :only => [:edit, :update]
  before_filter :load_all_product_associations,     :only => [:index, :edit, :update]
  before_filter :load_application_settings,         :only => [:edit, :show, :update]
  before_filter :load_possible_allocations,         :only => [:edit, :update]



# View-related methods
  
  # Page for editing an existing product
  def edit
    authorize! :update, @product
  end


  # Has two tabs, one with all products in the user's groups, another with all products.
  def index
    @groups = Group.order(:name)
    @products = Product.order(:name)
    @product = Product.new
    @user_group_products = Product.where(:id => ProductGroup.where(:group_id =>
          @current_user.employee_groups.pluck(:group_id)).pluck(:product_id)).order(:name)
    if params[:product_state] && !params[:product_state][:id].blank?
      @product_state = params[:product_state][:id]
      @products = @products.where(:product_state_id => params[:product_state][:id])
      @user_group_products = @user_group_products.where(:product_state_id =>
                             params[:product_state][:id])
    end
    if params[:product_type] && !params[:product_type][:id].blank?
      @product_type = params[:product_type][:id]
      @products = @products.where(:product_type_id => params[:product_type][:id])
      @user_group_products = @user_group_products.where(:product_type_id => 
                             params[:product_type][:id])
    end
    @products = @products.paginate(:page => params[:products_page], :per_page =>
          session[:results_per_page])
    @user_group_products = @user_group_products.paginate(:page => params[:user_group_products_page], 
          :per_page => session[:results_per_page])
  end


  # Page for viewing a product in detail
  def show
    @total_groups = @product.groups.length
    @total_services = @product.services.length
    @total_employees = @product.employee_products.where(:fiscal_year_id => @year.id).length
    @total_allocation = @product.get_total_allocation(@year)
  end



# Action-related methods 

  # Creates a new product using info entered on the "new" page
  def create
    authorize! :create, Product
    @product = Product.new(params[:product])
    if @product.save
      if params[:product_groups]
        unless params[:product_groups][:group_id].blank?
          new_product_group = @product.product_groups.new(params[:product_groups])
          new_product_group.save
        end
      end
      flash[:notice] = t(:product) + t(:created)
      redirect_to edit_product_path(@product.id)
      return
    end
    flash[:error] = t(:product) + t(:needs_a_name)
    render :index
  end


  # Hurls selected product into the nearest black hole
  def destroy
    authorize! :destroy, @product
    @product.destroy 
    flash[:notice] = t(:product) + t(:deleted)
    redirect_to products_path 
  end


  # Updates an existing product using info entered on the "edit" page
  def update
    authorize! :update, @product
    # If a new service was sent with the params, adds it to the product's list of services
    unless params[:product_service].blank? || params[:product_service][:service_id].blank?
      new_product_service = @product.product_services.new(params[:product_service])
      new_product_service.save
    end
    # If a new group was sent with the params, adds it to the product's list of group
    unless params[:product_group].blank? || params[:product_group][:group_id].blank?
      new_product_group = @product.product_groups.new(params[:product_group])
      new_product_group.save
    end
    # If a new employee was sent with the params, adds them to the product
    unless params[:employee_product].blank? || params[:employee_product][:employee_id].blank?
      new_employee_product = @product.employee_products.new(params[:employee_product])
      new_employee_product.save
    end
    if @product.update_attributes(params[:product])
      flash[:notice] = t(:product) + t(:updated)      
      redirect_to edit_product_path(@product.id)
      return
    end
    flash[:error] = "Product needs a name."
    render :edit
  end



# Loading methods

  private
    # Loads all active years. Loads the last selected year if it is active
    def load_active_years
      @active_years = FiscalYear.active_fiscal_years
      if cookies[:year].blank? || !(@year = FiscalYear.find_by_year(cookies[:year])).active
        @year = @current_fiscal_year
      end
    end
    
    
    # Loads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      if cookies[:year].blank?
        @year = @current_fiscal_year
      else
        @year = FiscalYear.find_by_year(cookies[:year])
      end
    end
  
  
    # Loads all product states, product types, and product sources
    def load_all_product_associations
      @product_states = ProductState.order(:name)
      @product_types = ProductType.order(:name)
      @product_source_types = ProductSourceType.all
    end


    # Loads the application settings fte_hours_per_week and allocation_precision
    def load_application_settings
      @fte_hours_per_week = AppSetting.get_fte_hours_per_week
      @allocation_precision = AppSetting.get_allocation_precision
    end


    # Loads all employees, groups, and services belonging to the product
    def load_associations
      @product_groups = @product.product_groups.joins(:group).includes(:group).order("groups.name")
      @product_services =
          @product.product_services.joins(:service).includes(:service).order("services.name")
      @employee_products = @product.employee_products.joins(:employee).where(
          :fiscal_year_id => @year.id).includes(:employee).order(:name_last, :name_first)
    end


    # Loads all groups and services not assigned to the product, and all employees not assigned to 
    # the product for the given year
    def load_available_associations
      @available_groups = @product.get_available_groups
      @available_services = @product.get_available_services
      @available_employees = @product.get_available_employees(@year)
    end


    # Loads a product based on the id provided in params
    def load_product
      @product = Product.includes(:product_state, :product_type).find(params[:id])
    end


    # Loads possible allocations
    def load_possible_allocations
      @possible_allocations = EmployeeProduct.possible_allocations
    end
end
