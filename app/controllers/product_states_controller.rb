class ProductStatesController < ApplicationController
  
  
  # View with a list of all current product states, and a form to add additional states
  def index
    @new_product_state = ProductState.new
    @product_states = ProductState.order(:name)
  end
  
  
  #
  def update
    product_state = ProductState.find(params[:id])
    unless product_state.update_attributes(params[:product_state])
      flash[:error] = "Product state needs a name"
      render :index
      return
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to product_states_path
  end


  # 
  def create
    if ProductState.create(params[:product_state])
      flash[:notice] = "Product state created"
      redirect_to product_states_path
      return
    end
    flash[:error] = "Product state needs a name"
    render :index
  end


  def destroy
    product_state = ProductState.find(params[:id])
    product_state.destroy
    flash[:notice] = "Product state deleted"
    redirect_to product_states_path
  end
end
