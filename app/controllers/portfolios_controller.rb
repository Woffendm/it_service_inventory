class PortfoliosController < ApplicationController
  before_filter :load_portfolio,  :only => [:edit, :update, :destroy, :show]
  before_filter :load_all_years,  :only => [:edit, :update, :show]
  before_filter :load_groups,     :only => [:index]
  before_filter :load_products,   :only => [:index, :edit, :update]
  before_filter :load_possible_groups, :only => [:edit, :update]
  
  
  
  # View for editing a portfolio.
  def edit
  end
  
  
  # View of all portfolios
  def index
    @new_portfolio = Portfolio.new
    @portfolios = filter_portfolios(params[:search])
    @portfolios = sort_results(params, @portfolios) unless params[:order].blank?
    @portfolios = @portfolios.includes(:products, :products => :groups).order("portfolios.name, products.name, groups.name").uniq
    @portfolios = @portfolios.paginate(:page => params[:page], 
                                     :per_page => session[:results_per_page])
  end
  
  
  # View a portfolio in detail
  def show
    @products = @portfolio.products.includes(:groups).order("products.name", "groups.name").uniq.paginate(:page => params[:products_page], 
                :per_page => session[:results_per_page])
    @total_allocation = @portfolio.get_total_allocation(@year, @allocation_precision)
    @groups = Group.includes(:product_group_portfolios => :product).where(:product_group_portfolios => {:portfolio_id => @portfolio.id}).order("groups.name", "products.name").uniq
  end
  
  
  # Creates new portfolio. 
  def create
    @portfolio = Portfolio.new(params[:portfolio])
    if @portfolio.save
      flash[:notice] = "Portfolio created!"
      redirect_to edit_portfolio_path(@portfolio.id)
      return
    else
      flash[:error] = "Portfolio already exists"
      redirect_to portfolios_path
    end
  end
  
  
  # Destroys given portfolio and redirects to its parent group.
  def destroy
    @portfolio.destroy
    flash[:notice] = t(:portfolio) + t(:deleted)
    redirect_to portfolios_path
  end
  
  
  # Adds new product to the portfolio if one is supplied, removes any which were marked for removal.
  # If a new product is added, also adds it to the group's list of products if it is not already in 
  # it. 
  def update
    unless params[:new_product_group_portfolios].blank?
      params[:new_product_group_portfolios].to_a.each do |new_pg|
        new_pg = new_pg.last
        unless new_pg.blank? || new_pg["product_id"].blank?
          if @portfolio.product_group_portfolios.new(new_pg).save
            flash[:notice] = "Product added."
          end
        end
      end
    end
    @portfolio.update_attributes(params[:portfolio])
    flash[:notice] = "Portfolio updated"
    redirect_to edit_portfolio_path(@portfolio.id)
  end
  
  
  
  private 
    # Filters the portfolios displayed on the index page based on paramaters provided
    def filter_portfolios(search)
      portfolios = Portfolio.where(true)
      return portfolios if search.blank?
      @group = search[:group]
      @product = search[:product]
      @name = search[:name]
      search_array = []
      search_array << "product_group_portfolios.group_id = #{@group}" unless @group.blank? 
      search_array << "product_group_portfolios.product_id = #{@product}" unless @product.blank? 
      search_string = search_array.join(" AND ")
      portfolios = portfolios.joins(:product_group_portfolios).uniq unless search_string.blank?
      portfolios = portfolios.where(search_string) unless search_string.blank?
      portfolios = portfolios.where("portfolios.name LIKE '%#{@name}%'") unless @name.blank?
      return portfolios
    end

    
    # Loads all years. Loads the last selected year
    def load_all_years
      @all_years = FiscalYear.order(:year)
      @year = FiscalYear.find_by_year(cookies[:year])
      @year = @current_fiscal_year if @year.blank?
    end
  
  
    # Loads all groups in alphabetical order
    def load_groups
      @groups = Group.order(:name)
    end
  
  
    # Loads the portfolio in question. Also loads its associated group
    def load_portfolio
      @portfolio = Portfolio.find(params[:id])
    end
    
    
    # Loads all groups that the current user can edit, along with any allocations that those 
    # may have
    def load_possible_groups
      if can? :manage, :all
        @possible_groups = Group.order(:name)
      else
        @possible_groups = @current_user.admin_groups
      end
      @groups_with_product_group_portfolios = Group.where("groups.id IN (?)", @possible_groups.pluck(:id) ).includes(:product_group_portfolios => :product).where(:product_group_portfolios => {:portfolio_id => @portfolio.id}).order("groups.name", "products.name").uniq
    end

    
    # Loads all products
    def load_products
      @products = Product.order(:name)
    end
end
