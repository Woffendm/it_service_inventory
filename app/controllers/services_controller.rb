# This class controls the Service model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class ServicesController < ApplicationController
  before_filter :load_service,      :only => [:destroy, :edit, :show, :update]
  before_filter :load_all_years,    :only => [:show, :groups]
  before_filter :load_associations, :only => [:show]
  
  
# View-related methods
  
  # Page for editing an existing service
  def edit
    authorize! :update, @service
  end
  
  
  # List of all services
  def index
    @groups = Group.order(:name)
    @services = filter_services(params[:search])
    @services = sort_results(params, @services)
    @services = @services.paginate(:page => params[:page], 
                :per_page => session[:results_per_page])
    @service = Service.new
  end
  
  
  def show
    @total_employees = @employee_allocations.length
    @total_groups = @groups.length
    @total_products = @service.product_services.length
    @total_allocation = @service.get_total_allocation(@year, @allocation_precision)
  end


# Action-related methods 

  # Creates a new service using info entered on the "new" page
  def create
    authorize! :create, Service
    @service = Service.new(params[:service])
    if @service.save
      flash[:notice] = t(:service) + t(:created)
    else
      flash[:error] = t(:service) + t(:needs_a_name)
    end
    redirect_to services_path  
  end


  # Hurls selected service into the nearest black hole
  def destroy
    authorize! :destroy, @service
    @service.destroy 
    flash[:notice] = t(:service) + t(:deleted)
    redirect_to services_path 
  end


  # Populates the group dropdown list on the "pages/home" page based on the service selected
  def groups
    @selected_group = params[:selected_group]
    if params[:service][:id] == "0"
      @groups = Group.joins(:employees).uniq.order(:name)
    else 
      @service = Service.find(params[:service][:id])
      @groups = @service.groups(@year)
    end
    render :layout => false
  end


  # Updates an existing service using info entered on the "edit" page
  def update
    authorize! :update, @service
    if @service.update_attributes(params[:service])
      flash[:notice] = t(:service) + t(:updated)
    else
      flash[:error] = t(:service) + t(:needs_a_name)
    end
    redirect_to edit_service_path(@service.id) 
  end



# Loading methods

  private
  # Filters the services displayed on the index page based on paramaters provided
  def filter_services(search)
    return Service.where(true) if search.blank?
    @group = search[:group]
    @name = search[:name]
    @search_string = ""
    @search_array = ["true"]
    @search_array << "services.name LIKE '%#{@name}%'" unless @name.blank? 
    @search_string = @search_array.join(" AND ")
    @services = Service.where(@search_string)
    @services = @services.joins(:employees => :groups).where("groups.id" => @group).uniq unless @group.blank?
    return @services
  end
  
  
    # Loads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      @year = FiscalYear.find_by_year(cookies[:year])
      @year = @current_fiscal_year if @year.blank?
    end
  
  
    # Loads all employees allocated to this service
    def load_associations
      @employee_allocations = @service.employee_allocations.joins(:employee).where(
          :fiscal_year_id => @year.id).includes(:employee).order(:name_last, :name_first)
      @products = @service.products.order(:name)
      @groups = @service.groups(@year).order(:name)
    end
    
    
    # Loads a service based on the id provided in params
    def load_service
      @service = Service.find(params[:id])
    end
end
