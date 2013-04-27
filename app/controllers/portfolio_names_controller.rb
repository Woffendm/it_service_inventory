# This class controls Portfolio Names.
#
# Author: Michael Woffendin 
# Copyright:

class PortfolioNamesController < ApplicationController

  # View with a list of all current product states, and a form to add additional states
  def index
    @new_portfolio_name = PortfolioName.new
    @portfolio_names = PortfolioName.order(:name)
  end
  
  
  # Updates a product state's name
  def update
    portfolio_name = PortfolioName.find(params[:id])
    unless portfolio_name.update_attributes(params[:portfolio_name])
      flash[:error] = "Portfolio name must be unique"
      render :index
      return
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to portfolio_names_path
  end


  # Creates a new product state
  def create
    if PortfolioName.new(params[:portfolio_name].merge({"global" => true})).save
      flash[:notice] = "Portfolio name created"
      redirect_to portfolio_names_path
      return
    end
    flash[:error] = "Portfolio name must be unique"
    redirect_to portfolio_names_path
  end


  # Destroys a product state
  def destroy
    portfolio_name = PortfolioName.find(params[:id])
    portfolio_name.destroy
    flash[:notice] = "Portfolio name deleted"
    redirect_to portfolio_names_path
  end
end
