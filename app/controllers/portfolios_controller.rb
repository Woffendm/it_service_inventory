class PortfoliosController < ApplicationController
  before_filter :load_portfolio
  
  
  # View for editing a portfolio.
  def edit
    @portfolio_products = @portfolio.portfolio_products.joins(:product).order(:name)
    @possible_products = Product.order(:name) - @portfolio.products
  end
  
  
  # Destroys given portfolio and redirects to its parent group.
  def destroy
    @group = Group.find(@portfolio.group_id)
    @portfolio.destroy
    flash[:notice] = t(:portfolio) + t(:deleted)
    redirect_to edit_groups_path(@group)
  end
  
  
  # Adds new product to the portfolio if one is supplied, removes any which were marked for removal. 
  def update
    unless params[:product].blank? || params[:product][:id].blank?
      @portfolio.products << Product.find(params[:product][:id])
      flash[:notice] = "Product added!"
    end
    if @portfolio.update_attributes(params[:portfolio])
      flash[:notice] = "Yay!"
      redirect_to edit_portfolio_path(@portfolio.id)
      return
    else
      flash[:error] = "Oh no!"
      render :edit
    end
  end
  
  
  private 
    # Loads the portfolio in question.
    def load_portfolio
      @portfolio = Portfolio.find(params[:id])
    end
end
