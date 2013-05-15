# This class controls Product Types, which are used to determine the status of products.
#
# Author: Michael Woffendin 
# Copyright:

class ProductTypesController < ApplicationController
  
  before_filter :load_permissions
  before_filter :load_product_types, :only => [:index, :create, :update]
  
  
  # View with a list of all current product types, and a form to add additional types
  def index

  end
  
  
  # Updates a product type's name
  def update
    product_type = ProductType.find(params[:id])
    unless product_type.update_attributes(params[:product_type])
      flash[:error] = "Product type needs a unique name"
      render :index
      return
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to product_types_path
  end


  # Creates a new product type
  def create
    unless ProductType.new(params[:product_type]).save
      flash[:error] = "Product type needs a unique name"
      render :index
      return
    end
    flash[:notice] = "Product type created"
    redirect_to product_types_path
  end


  # Destroys a product type
  def destroy
    product_type = ProductType.find(params[:id])
    product_type.destroy
    flash[:notice] = "Product type deleted"
    redirect_to product_types_path
  end
  
  
  private
    # Only authorized users can view and edit app settings 
    def load_permissions
      authorize! :manage, :all
    end
    
    
    # Loads all product types and creates a blank new one
    def load_product_types
      @new_product_type = ProductType.new
      @product_types = ProductType.order(:name)
    end
end
