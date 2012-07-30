# This class controls the Service model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class ServicesController < ApplicationController
  before_filter :load_service, :only => [:update, :destroy, :edit]
  before_filter :load_permissions

  
# View-related methods
  
  # Page for editing an existing service
  def edit
  end
  
  
  # List of all services
  def index
    @services = Service.order(:name).paginate(:page => params[:page], 
                :per_page => session[:results_per_page])
    @service = Service.new
  end
  


# Action-related methods 

  # Creates a new service using info entered on the "new" page
  def create
    @service = Service.new(params[:service])
    if @service.save
      flash[:notice] = "Service created!"
      redirect_to services_path
      return
    end
    render :new
  end


  # Hurls selected service into the nearest black hole
  def destroy
    authorize! :destroy, Service
    @service.destroy 
    flash[:notice] = "Service deleted!"
    redirect_to services_path 
  end


  # Updates an existing service using info entered on the "edit" page
  def update
    if @service.update_attributes(params[:service])
      flash[:notice] = "Service updated!"
      redirect_to services_path 
      return
    end
    render :edit
  end
  


# Loading methods

  private
    # Loads permissions. Only group admins and site admins can do things to services
    def load_permissions
      authorize! :update, Service
    end
  
  
    # Loads a service based on the id provided in params
    def load_service
      @service = Service.find(params[:id])
    end
end
