# This class controls Product Types, which are used to determine the type of products.
#
# Author: Michael Woffendin 
# Copyright:

class ProductTypesController < ApplicationController
  
  # View with a list of all current product types, and a form to add additional types
  def index
    @new_product_type = ProductType.new
    @product_types = ProductType.order(:name)
  end
  
  
  # Updates a product type's name
  def update
    product_type = ProductType.find(params[:id])
    unless product_type.update_attributes(params[:product_type])
      flash[:error] = "Product type needs a name"
      render :index
      return
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to product_types_path
  end


  # Creates a new product type
  def create
    if ProductType.new(params[:product_type]).save
      flash[:notice] = "Product type created"
      redirect_to product_types_path
      return
    end
    flash[:error] = "Product type needs a unique name"
    render :index
  end


  # Destroys a product type
  def destroy
    product_type = ProductType.find(params[:id])
    product_type.destroy
    flash[:notice] = "Product type deleted"
    redirect_to product_types_path
  end
end
