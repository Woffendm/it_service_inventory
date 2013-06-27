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
    if can? :manage, :all
      @groups = Group.order(:name)
    else
      @groups = @current_user.admin_groups
    end
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
    @groups = @product.groups.order(:name).uniq
    @total_groups = @groups.length
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
    add_service(params[:product_service])
    # 
    unless params[:new_product_groups].blank?
      params[:new_product_groups].to_a.each do |new_pg|
        new_pg = new_pg.last
        unless new_pg.blank? || new_pg["group_id"].blank?
          if @product.product_groups.new(new_pg).save
            flash[:notice] = "Product added."
          else
            flash[:error] = "Cannot add group"
            render :edit
            return
          end
        end
      end
    end
    unless params[:new_product_portfolio].blank? || 
           params[:new_product_portfolio][:portfolio_id].blank?
      @product.portfolios << Portfolio.find(params[:new_product_portfolio][:portfolio_id])
      flash[:notice] = t(:portfolio) + t(:added)
    end
    unless params[:new_portfolio].blank? || params[:new_portfolio][:name].blank?
      new_portfolio = Portfolio.new(params[:new_portfolio])
      if new_portfolio.save
        @product.portfolios << new_portfolio
        flash[:notice] = t(:portfolio) + t(:created)
      else
        flash[:error] = "Portfolio already exists"
        render :edit
        return
      end
    end
    # If a new employee was sent with the params, adds them to the product
    unless params[:employee_product].blank? || params[:employee_product][:employee_id].blank? ||
           params[:employee_product][:fiscal_year_id].blank?
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






  private
  
  # Helper methods
  
    #
    def add_group(new_product_groups)
      new_product_groups.blank?
        new_product_groups.to_a.each do |new_pg|
          new_pg = new_pg.last
          unless new_pg.blank? || new_pg["group_id"].blank?
            if @product.product_groups.new(new_pg).save
              flash[:notice] = "Group added."
            else
              flash[:error] = "Cannot add group"
              render :edit
              return
            end
          end
        end
      end
    end
    
    
    # Adds service to product
    def add_service(product_service)
      unless product_service.blank? || product_service[:service_id].blank?
        new_product_service = @product.product_services.new(product_service)
        if new_product_service.save
          flash[:notice] = "Service added."
        else
          flash[:error] = "Cannot add service"
          render :edit
          return
        end
      end
    end
    
  
    # Removes product from selected portfolio
    def remove_from_portfolio(remove_portfolios)
      unless remove_portfolios.blank?
        remove_portfolios.to_a.each do |portfolio|
          portfolio = portfolio.last
          unless portfolio.blank? || portfolio["portfolio_id"].blank?
            ProductPortfolio.where(:portfolio_id => portfolio["portfolio_id"], :product_id => @product.id).first.destroy
          end
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
      @product_source_types = ProductSourceType.all
    end


    # Loads the application setting fte_hours_per_week 
    def load_application_settings
      @fte_hours_per_week = AppSetting.fte_hours_per_week
    end


    # Loads all employees, groups, and services belonging to the product
    def load_associations
      @portfolios = @product.portfolios.order(:name).uniq
      @product_services =
          @product.product_services.joins(:service).includes(:service).order("services.name")
      @employee_products = @product.employee_products.joins(:employee).where(
          :fiscal_year_id => @year.id).includes(:employee).order(:last_name, :first_name)
    end


    # Loads all groups and services not assigned to the product, and all employees not assigned to 
    # the product for the given year
    def load_available_associations
      @possible_portfolios = @product.get_available_portfolios
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
