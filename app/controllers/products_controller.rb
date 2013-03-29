# This class controls the Product model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class ProductsController < ApplicationController
  before_filter :load_product,                      :only => [:destroy, :edit, :show, :update]
  before_filter :load_application_settings,         :only => [:edit, :show, :update]
  before_filter :load_active_years,                 :only => [:edit, :update]
  before_filter :load_all_years,                    :only => [:show]
  before_filter :load_associations,                 :only => [:edit, :show, :update]
  before_filter :load_available_associations,       :only => [:edit, :update]
  before_filter :load_all_product_associations,     :only => [:index, :edit, :update]
  before_filter :load_possible_allocations,         :only => [:edit, :update]


# View-related methods
  
  # Page for editing an existing product
  def edit
    authorize! :update, @product
  end


  # Page for viewing all products at a glance. 
  # Contains rest services for viewing products in json
  def index
    @groups = Group.order(:name)
    @product = Product.new
    @products = filter_products(params[:search])
    @products = sort_results(params, @products)
    @products = @products.paginate(:page => params[:products_page], :per_page =>
          session[:results_per_page])
    respond_to do |format|
      format.html
      format.js  { render :json => Product.rest_show_all, :callback => params[:callback] }
      format.json { render :json => Product.rest_show_all }
      format.xml { render :xml => @products }
    end
  end


  # Page for viewing a product in detail
  # Contains rest services for viewing product in json
  def show
    @product = Product.find(params[:id])
    @total_groups = @product.groups.length
    @total_services = @product.services.length
    @total_employees = @product.employee_products.where(:fiscal_year_id => @year.id).length
    @total_allocation = @product.get_total_allocation(@year, @allocation_precision)
    respond_to do |format|
      format.html
      format.js  { render :json => @product.rest_show, :callback => params[:callback] }
      format.json { render :json => @product.rest_show }
      format.xml { render :xml => @product }
    end
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
    redirect_to products_path
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
    # Filters the products displayed on the index page based on paramaters provided
    def filter_products(search)
      return Product.where(true) if search.blank?
      @group = search[:group]
      @product_state = search[:product_state]
      @product_type = search[:product_type]
      @product_name = search[:product_name]
      @product_priority = search[:product_priority]
      @search_string = ""
      @search_array = ["true"]
      @search_array << "products.name LIKE '%#{@product_name}%'" unless @product_name.blank? 
      @search_array << "product_state_id = #{@product_state}" unless @product_state.blank?
      @search_array << "product_type_id = #{@product_type}" unless @product_type.blank? 
      @search_array << "product_priority_id = #{@product_priority}" unless @product_priority.blank? 
      @search_string = @search_array.join(" AND ")
      @products = Product.where(@search_string)
      @products = @products.joins(:groups).where("product_groups.group_id" => @group).uniq unless @group.blank?
      return @products
    end
    
    
    # Loads all active years. Loads the last selected year if it is active
    def load_active_years
      @active_years = FiscalYear.active_fiscal_years
      if cookies[:year].blank? || !(@year = FiscalYear.find_by_year(cookies[:year])).active
         flash[:message] = "Selected year #{@year.year} inactive. Year changed to #{@current_fiscal_year.year}." if @year
        @year = @current_fiscal_year
      else 
        @year = FiscalYear.find_by_year(cookies[:year])
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
      @product_priorities = ProductPriority.order(:name)
      @product_source_types = ProductSourceType.all
    end


    # Loads the application setting fte_hours_per_week 
    def load_application_settings
      @fte_hours_per_week = AppSetting.get_fte_hours_per_week
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
      @product = Product.includes(:product_state, :product_type,
                :product_priority).find(params[:id])
    end


    # Loads possible allocations
    def load_possible_allocations
      @possible_allocations = EmployeeProduct.possible_allocations(@allocation_precision)
    end
end
