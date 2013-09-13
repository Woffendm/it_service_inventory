# This class controls the Product model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class ProductsController < ApplicationController
  before_filter :load_product,                      :except => [:index, :create]
  before_filter :authorize_update,                  :except => [:create, :show, :index]
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
  end


  # Page for viewing all products at a glance. 
  # Contains rest services for viewing products in json
  def index
    @groups = Group.order(:name)
    @new_product = Product.new
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
    @dependencies = @product.dependencies.order(:name).paginate(
        :page => params[:dependencies_page], 
        :per_page => session[:results_per_page])
    @dependents = @product.dependents.order(:name).paginate(
        :page => params[:dependents_page], 
        :per_page => session[:results_per_page])
    @groups = @product.groups.order(:name).uniq
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
      unless params[:product_groups].blank? || params[:product_groups][:group_id].blank?
        new_product_group = @product.product_groups.create(params[:product_groups])
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


  # Removes product dependency
  def remove_dependency
    to_remove = Product.find(params[:product_id])
    @product.dependencies.delete to_remove
    flash[:notice] = "Dependency removed"
    redirect_to edit_product_path(@product.id)
  end
  
  
  # Removes product dependent
  def removed_dependent
    to_remove = Product.find(params[:product_id])
    @product.dependents.delete to_remove
    flash[:notice] = "Dependency removed"
    redirect_to edit_product_path(@product.id)
  end


  # Removes product from selected portfolio
  def remove_from_portfolio
    product_portfolio = ProductPortfolio.where(:portfolio_id => params[:portfolio_id], 
                                               :product_id => @product.id).first
    if product_portfolio && product_portfolio.destroy
      flash[:notice] = "Portfolio removed"
    end
    redirect_to edit_product_path(@product.id)
  end


  # Updates an existing product using info entered on the "edit" page
  def update
    add_dependent(params[:new_dependent])
    add_dependency(params[:new_dependency])
    new_product_service(params[:product_service])
    new_product_group_portfolio(params[:new_product_group_portfolios])
    new_product_portfolio(params[:new_product_portfolio])
    new_employee_product(params[:employee_product])
    new_portfolio(params[:new_portfolio])
    new_product_group(params[:new_product_group])
    if @product.update_attributes(params[:product])
      flash[:notice] = t(:product) + t(:updated)      
    else
      flash[:error] = t(:product) + t(:needs_a_name)
      @error = true
    end
    if @error.blank?
      redirect_to edit_product_path(@product.id)
    else
      render :edit
    end
  end








  private
  # Helper methods
  
    # Ensures that the current user is authorized to update the product
    def authorize_update
      authorize! :update, @product
    end
  
  
    # Adds new dependency to product (something it depends on)
    def add_dependency(dependency)
      unless dependency.blank? || dependency[:product_id].blank?
        @product.dependencies << Product.find(dependency[:product_id])
      end
    end
    
    
    # Adds new dependent to product (something that depends on the product)
    def add_dependent(dependent)
      unless dependent.blank? || dependent[:product_id].blank?
        @product.dependents << Product.find(dependent[:product_id])
      end    
    end
  
  
    # Adds new employee allocation to product
    def new_employee_product(employee_product)
      unless employee_product.blank? || employee_product[:employee_id].blank?
        new_employee_product = @product.employee_products.new(params[:employee_product])
        new_employee_product.save
        flash[:notice] = "Employee allocated"
      end
    end
  
  
    # Adds product to the specified group's portfolio
    def new_product_group_portfolio(new_product_group_portfolios)
      unless new_product_group_portfolios.blank?
        new_product_group_portfolios.to_a.each do |new_pg|
          new_pg = new_pg.last
          unless new_pg.blank? || new_pg["group_id"].blank?
            if @product.product_group_portfolios.new(new_pg).save
              flash[:notice] = "Group added."
            else
              flash[:error] = "Cannot add group"
              @error = true
            end
          end
        end
      end
    end
    
    
    # Adds service to product
    def new_product_service(product_service)
      unless product_service.blank? || product_service[:service_id].blank?
        new_product_service = @product.product_services.new(product_service)
        if new_product_service.save
          flash[:notice] = "Service added."
        else
          flash[:error] = "Cannot add service"
          @error = true
        end
      end
    end
    
    
    # Adds portfolio to product's list of portfolios
    def new_product_portfolio(new_product_portfolio)
      unless new_product_portfolio.blank? || new_product_portfolio[:portfolio_id].blank?
        @product.portfolios << Portfolio.find(new_product_portfolio[:portfolio_id])
        flash[:notice] = t(:portfolio) + t(:added)
      end
    end
    
    
    # Creates a new portfolio
    def new_portfolio(new_portfolio)
      unless new_portfolio.blank? || new_portfolio[:name].blank?
        portfolio = Portfolio.new(new_portfolio)
        if portfolio.save
          @product.portfolios << portfolio
          flash[:notice] = t(:portfolio) + t(:created)
        else
          flash[:error] = "Portfolio already exists"
          @error = true
        end
      end
    end
    
    
    
    def new_product_group(product_group)
      unless product_group.blank? || product_group[:group_id].blank?
        if @product.product_groups.new(product_group).save
          flash[:notice] = t(:group) + t(:added)
        else
          flash[:error] = "Cannot add group"
          @error = true
        end
      end
    end
  
  
  
  
  
  
  
  
  # Loading methods
  
    # Filters the products displayed on the index page based on paramaters provided
    def filter_products(search)
      return Product.where(true) if search.blank?
      @group = search[:group]
      @name = search[:name]
      @product_state = search[:product_state]
      @product_type = search[:product_type]
      @product_priority = search[:product_priority]
      @search_string = ""
      @search_array = ["true"]
      @search_array << "products.name LIKE '%#{@name}%'" unless @name.blank? 
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
  
  
    # Loads all product states, product types, and product sources
    def load_all_product_associations
      @product_states = ProductState.order(:name)
      @product_types = ProductType.order(:name)
      @product_priorities = ProductPriority.order(:name)
    end


    # Loads the application setting fte_hours_per_week 
    def load_application_settings
      @fte_hours_per_week = AppSetting.fte_hours_per_week
    end


    # Loads all employees, groups, and services belonging to the product
    def load_associations
      @dependencies = @product.dependencies.order(:name)
      @dependents = @product.dependents.order(:name)
      @portfolios = @product.portfolios.order(:name).uniq
      @product_groups = @product.product_groups.includes(:group).order("groups.name")
      @product_services = @product.product_services.includes(:service).order("services.name")
      @employee_products = @product.employee_products.joins(:employee).where(
          :fiscal_year_id => @year.id).includes(:employee).order(:last_name, :first_name)
    end


    # Loads all groups and services not assigned to the product, and all employees not assigned to 
    # the product for the given year
    def load_available_associations
      @possible_portfolios = @product.get_available_portfolios
      @available_groups = @product.get_available_groups
      @available_services = @product.get_available_services
      @available_employees = @product.get_available_employees(@year)
      @available_dependencies = Product.order(:name) - @product.dependencies - [@product]
      @available_dependents = Product.order(:name) - @product.dependents - [@product]
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
