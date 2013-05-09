# This class controls Product Priorities, which are used to determine the status of products.
#
# Author: Michael Woffendin 
# Copyright:

class ProductPrioritiesController < ApplicationController
  
  before_filter :load_product_priorities, :only => [:index, :create, :update]
  
  
  # View with a list of all current product priorities, and a form to add additional priorities
  def index
  end
  
  
  # Updates a product priority's name
  def update
    product_priority = ProductPriority.find(params[:id])
    unless product_priority.update_attributes(params[:product_priority])
      flash[:error] = "Product priority needs a unique name"
      render :index
      return
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to product_priorities_path
  end


  # Creates a new product priority
  def create
    if ProductPriority.new(params[:product_priority]).save
      flash[:notice] = "Product priority created"
      redirect_to product_priorities_path
      return
    end
    flash[:error] = "Product priority needs a unique name"
    render :index
  end


  # Destroys a product priority
  def destroy
    product_priority = ProductPriority.find(params[:id])
    product_priority.destroy
    flash[:notice] = "Product priority deleted"
    redirect_to product_priorities_path
  end
  
  
  private
    # Loads all existing product priorities and creates new blank product priority
    def load_product_priorities
      @new_product_priority = ProductPriority.new
      @product_priorities = ProductPriority.order(:name)
    end
end
