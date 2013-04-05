class PortfoliosController < ApplicationController
  before_filter :load_portfolio
  
  
  
  def edit
    @portfolio_products = @portfolio.portfolio_products.joins(:products).order(:name)
    @possible_products = Product.order(:name) - @portfolio.products
  end
  
  
  def update
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
    def load_portfolio
      @portfolio = Portfolio.find(params[:id])
    end
end
