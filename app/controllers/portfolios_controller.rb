class PortfoliosController < ApplicationController
  before_filter :load_portfolio
  before_filter :load_product,      :only => [:update]
  
  
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
  # If a new product is added, also adds it to the group's list of products if it is not already in 
  # it. 
  def update
    unless params[:product].blank? || params[:product][:id].blank?
      @portfolio.products << @product
      flash[:notice] = "Product added!"
      if ProductGroup.where(:product_id => @product.id, :group_id => @portfolio.group_id).blank?
        Group.find(@portfolio.group_id).products << @product
      end
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
    
    
    # Loads the product being added
    def load_product
      unless params[:product].blank? || params[:product][:id].blank?
        @product = Product.find(params[:product][:id])
      end
    end
end
