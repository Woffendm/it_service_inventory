class PortfoliosController < ApplicationController
  before_filter :load_portfolio,  :only => [:edit, :update, :destroy]
  before_filter :load_product,    :only => [:update]
  before_filter :load_all_years,  :only => [:edit]    
  before_filter :load_group,      :only => [:new, :create]                            
  before_filter :load_groups,     :only => [:index]
  before_filter :load_products,   :only => [:index]
  before_filter :load_portfolio_names, :only => [:new, :create]
  
  
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
    portfolio_names = filter_portfolios(params[:search])
    portfolio_names = sort_results(params, portfolio_names) unless params[:order].blank?
    @portfolio_names = portfolio_names.includes(:products, :portfolios => :group).uniq.order("portfolio_names.name", "products.name", "groups.name")
  end
  
  
  # Page for creating a new portfolio
  def new
    @portfolio = Portfolio.new
  end
  
  
  # Creates new portfolio. 
  def create
    @name = params[:name]
    unless @name.blank?
      @portfolio_name = PortfolioName.find_by_name(@name)
      @portfolio_name = PortfolioName.create(:name => @name) if @portfolio_name.blank?
      @portfolio = Portfolio.new(:group_id => params[:group_id], 
                                 :portfolio_name_id => @portfolio_name.id)
    else
      @portfolio = Portfolio.new(params[:portfolio])
    end
    if @portfolio.save
      flash[:notice] = "Portfolio created!"
      redirect_to edit_portfolio_path(@portfolio.id)
      return
    else
      flash[:error] = "Group already has a portfolio with this name"
      render :new
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
      if @portfolio.portfolio_products.new(:product_id => params[:product][:id], 
          :portfolio_name_id => @portfolio.portfolio_name_id).save
        flash[:notice] = "Product added!"
      else
        flash[:error] = "Product cannot be added"
        render :edit
        return
      end
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
    # Filters the portfolios displayed on the index page based on paramaters provided
    def filter_portfolios(search)
      return PortfolioName.joins(:products) if search.blank?
      @group = search[:group]
      @product = search[:product]
      @portfolio_name = search[:portfolio_name]
      @global = search[:global]
      search_string = ""
      search_array = []
      search_array << "portfolios.group_id = #{@group}" unless @group.blank? 
      search_array << "products.id = #{@product}" unless @product.blank? 
      search_array << "portfolio_names.global = " + @global unless @global.blank? 
      search_string = search_array.join(" AND ")
      portfolio_names = PortfolioName.joins(:portfolios, :products => :portfolios)
      portfolio_names = portfolio_names.where(
            "portfolio_names.name LIKE '%#{@portfolio_name}%'") unless @portfolio_name.blank?
      portfolio_names = portfolio_names.where(search_string).uniq unless search_string.blank?
      return portfolio_names
    end

    
    # Loads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      @year = FiscalYear.find_by_year(cookies[:year])
      @year = @current_fiscal_year if @year.blank?
    end
  
  
    # Loads the group that the portfolio will belong to
    def load_group
      @group = params[:group_id]
      @group = params[:portfolio][:group_id] if @group.blank?
      @group = Group.find(@group)
    end
  
  
    # Loads all groups in alphabetical order
    def load_groups
      @groups = Group.order(:name)
    end
  
  
    # Loads the portfolio in question. Also loads its associated group
    def load_portfolio
      @portfolio = Portfolio.find(params[:id])
      @group = Group.find(@portfolio.group_id)
    end
    
    
    # Loads all global portfolio names
    def load_portfolio_names
      @portfolio_names = PortfolioName.global_portfolio_names - 
         PortfolioName.joins(:portfolios).where(:portfolios => {:group_id => @group.id})
    end
    
    
    # Loads the product being added
    def load_product
      unless params[:product].blank? || params[:product][:id].blank?
        @product = Product.find(params[:product][:id])
      end
    end
    
    
    def load_products
      @products = Product.order(:name)
    end
end
