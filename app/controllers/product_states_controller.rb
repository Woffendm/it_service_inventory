# This class controls Product States, which are used to determine the status of products.
#
# Author: Michael Woffendin 
# Copyright:

class ProductStatesController < ApplicationController
  
  before_filter :load_permissions
  before_filter :load_product_states, :only => [:index, :create, :update]
  
  
  # View with a list of all current product states, and a form to add additional states
  def index

  end
  
  
  # Updates a product state's name
  def update
    product_state = ProductState.find(params[:id])
    unless product_state.update_attributes(params[:product_state])
      flash[:error] = "Product state needs a unique name"
      render :index
      return
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to product_states_path
  end


  # Creates a new product state
  def create
    unless ProductState.new(params[:product_state]).save
      flash[:error] = "Product state needs a unique name"
      render :index
      return
    end
    flash[:notice] = "Product state created"
    redirect_to product_states_path
  end


  # Destroys a product state
  def destroy
    product_state = ProductState.find(params[:id])
    product_state.destroy
    flash[:notice] = "Product state deleted"
    redirect_to product_states_path
  end
  
  
  private
    # Only authorized users can view and edit app settings 
    def load_permissions
      authorize! :manage, :all
    end
    
    
    # Loads all product states and creates a blank new one
    def load_product_states
      @new_product_state = ProductState.new
      @product_states = ProductState.order(:name)
    end
end
