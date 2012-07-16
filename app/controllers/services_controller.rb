# This class controls the Service model, views, and related actions
#
# Author: Michael Woffendin 
# Copyright:

class ServicesController < ApplicationController
    before_filter :load_service, :only => [:update, :destroy, :edit]

  
# View-related methods
  
  # List of all services
  def index
    @services = Service.order(:name)
  end

  
  # Page for creating a new service
  def new
    @service = Service.new
  end

  
  # Page for editing an existing service
  def edit
  end



# Action-related methods 

  # Creates a new service using info entered on the "new" page
  def create
    @service = Service.new(params[:service])
    if @service.save
      redirect_to edit_service_path(@service.id)
      return
    end
    render :new
  end


  # Updates an existing service using info entered on the "edit" page
  def update
    if @service.update_attributes(params[:service])
      redirect_to edit_service_path 
      return
    end
      render :edit
  end


  # Hurls selected service into the nearest black hole
  def destroy
    @service.destroy 
    redirect_to services_path 
  end
  


# Loading methods

  private
    # Loads a service based on the id provided in params
    def load_service
      @service = Service.find(params[:id])
    end
end
