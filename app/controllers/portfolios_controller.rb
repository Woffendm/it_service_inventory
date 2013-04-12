class PortfoliosController < ApplicationController
  before_filter :load_portfolio
  before_filter :load_product,    :only => [:update]
  before_filter :load_all_years,  :only => [:edit]                                
  
  
  
  # View for editing a portfolio.
  def edit
    @portfolio_products = @portfolio.portfolio_products.joins(:product).order(:name)
    @product_allocations = []
    @portfolio_products.each do |portfolio_product|
      @product_allocations << portfolio_product.product.get_allocation_for_group(@group, @year, 
                              @allocation_precision).to_s + " " + t(:fte)
    end
    @possible_products = Product.order(:name) - @portfolio.products
  end
  
  
  # View of all portfolios
  def index
    @portfolio_array = []
    PortfolioName.order(:name).each do |portfolio_name| 
      product_array = []
      Product.joins(:portfolios).where(:portfolios => 
              {:portfolio_name_id => portfolio_name.id}).includes(
              :groups).order(:name).each do |product| 
        product_array << product 
      end
      @portfolio_array << [portfolio_name.name, product_array]
    end
  end
  
  
  # Destroys given portfolio and redirects to its parent group.
  def destroy
    @group = Group.find(@portfolio.group_id)
    @portfolio.destroy
    flash[:notice] = t(:portfolio) + t(:deleted)
    redirect_to edit_group_path(@group)
  end
  
  
  # Adds new product to the portfolio if one is supplied, removes any which were marked for removal.
  # If a new product is added, also adds it to the group's list of products if it is not already in 
  # it. 
  def update
    unless params[:product].blank? || params[:product][:id].blank?
      @portfolio.products << @product
      flash[:notice] = "Product added!"
      if ProductGroup.where(:product_id => @product.id, :group_id => @portfolio.group_id).blank?
        @group.products << @product
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
    # Loads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      if cookies[:year].blank?
        @year = @current_fiscal_year
      else
        @year = FiscalYear.find_by_year(cookies[:year])
      end
    end
  
  
    # Loads the portfolio in question. Also loads its associated group
    def load_portfolio
      @portfolio = Portfolio.find(params[:id])
      @group = Group.find(@portfolio.group_id)
    end
    
    
    # Loads the product being added
    def load_product
      unless params[:product].blank? || params[:product][:id].blank?
        @product = Product.find(params[:product][:id])
      end
    end
end
