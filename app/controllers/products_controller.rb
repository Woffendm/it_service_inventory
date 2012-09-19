# This class controls the Product model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class ProductsController < ApplicationController
  before_filter :load_product, :only => [:destroy, :edit, :update]
  before_filter :load_permissions
  before_filter :load_employees_services_groups, :only => [:edit, :update]
  before_filter :load_allocation_precision, :only => [:edit, :update]
  before_filter :load_possible_allocations, :only => [:edit, :update]



# View-related methods
  
  # Page for editing an existing product
  def edit
  end


  # List of all products
  def index
    @products = Product.order(:name).paginate(:page => params[:page], 
                :per_page => session[:results_per_page])
    @product = Product.new
  end



# Action-related methods 

  # Creates a new product using info entered on the "new" page
  def create
    @product = Product.new(params[:product])
    if @product.save
      flash[:notice] = t(:product) + t(:created)
    else
      flash[:error] = t(:product) + t(:needs_a_name)
    end
    redirect_to products_path  
  end


  # Hurls selected product into the nearest black hole
  def destroy
    authorize! :destroy, Product
    @product.destroy 
    flash[:notice] = t(:product) + t(:deleted)
    redirect_to products_path 
  end


  # Updates an existing product using info entered on the "edit" page
  def update
    # If a new service was sent with the params, adds it to the product's list of services
    if params[:product_services]
      unless params[:product_services][:service_id].blank?
        new_product_service = @product.product_services.new(params[:product_services])
        new_product_service.save
      end
    end
    # If a new employee was sent with the params, adds them to the product
    if params[:employee_products]
      unless params[:employee_products][:employee_id].blank?
        new_employee_product = @product.employee_products.new(params[:employee_products])
        new_employee_product.save
      end
    end
    if @product.update_attributes(params[:product])
      flash[:notice] = t(:product) + t(:updated)      
      redirect_to edit_product_path(@product.id)
      return
    end
    flash[:error] = ":'("
    render :edit
  end



# Loading methods

  private
    # Loads the application settings fte_hours_per_week and allocation_precision
    def load_allocation_precision
      @fte_hours_per_week = AppSetting.get_fte_hours_per_week
      @allocation_precision = AppSetting.get_allocation_precision
    end


    # Loads permissions. Only group admins and site admins can do things to products
    def load_permissions
      authorize! :update, Product
    end


    # Loads a product based on the id provided in params
    def load_product
      @product = Product.find(params[:id])
    end


    # Loads all employees and services belonging to the product, and all groups
    def load_employees_services_groups
      @services = @product.services.order(:name)
      @employees = @product.employees.order(:name_last, :name_first)
      @groups = Group.order(:name)
    end
    
    
    # Loads possible allocations
    def load_possible_allocations
      @possible_allocations = EmployeeProduct.possible_allocations
    end
end
