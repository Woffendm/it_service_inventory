class Portfolio < ActiveRecord::Base
    attr_accessible :name, :global, :group_portfolios, :group_portfolios_attributes,
                    :product_group_portfolios, :product_group_portfolios_attributes,  
                    :product_portfolios, :product_portfolios_attributes


    has_many  :product_group_portfolios,
              :dependent => :delete_all
    has_many  :product_portfolios,
              :dependent => :delete_all
    has_many  :products,
              :through => :product_portfolios
    has_many  :group_portfolios,
              :dependent => :delete_all
    has_many  :groups,
              :through => :group_portfolios


    accepts_nested_attributes_for :product_group_portfolios,
                                  :allow_destroy => true
    accepts_nested_attributes_for :group_portfolios,
                                  :allow_destroy => true


    validates_presence_of   :name
    validates_uniqueness_of :name



    # Returns all global portfolios
    def self.global_portfolios
      Portfolio.where(:global => true).order("portfolios.name")
    end


    # Returns the portfolio's group if it has one
    def group    
      return Group.find(self.group_id) unless self.group_id.blank?
    end


    # Returns all product groups belonging to the given group in this portfolio
    def product_group_portfolios_for_group(group)
      ProductGroupPortfolio.where(:group_id => group.id, :portfolio_id => self.id).includes(:product).order("products.name").uniq
    end
    
    
    # Returns all product groups belonging to the given product in this portfolio
    def product_group_portfolios_for_product(product)
      ProductGroupPortfolio.where(:product_id => product.id, :portfolio_id => self.id).includes(:group).order("groups.name").uniq
    end


    # Returns all products that the given group does not have in this portfolio
    def possible_products_for_group(group)
      Product.order(:name) - Product.joins(:product_group_portfolios).where(:product_group_portfolios => {:group_id => group.id, :portfolio_id => self.id}).uniq
    end
    
    
    # Returns all groups that the given product does not have in this portfolio
    def possible_groups_for_product(product)
      Group.order(:name) - Group.joins(:product_group_portfolios).where(:product_group_portfolios => {:product_id => product.id, :portfolio_id => self.id}).uniq
    end


    # Returns the group's total product allocation for the given portfolio
    def get_allocation_for_group(group, year, allocation_precision)
      total = 0.0
      self.product_group_portfolios.where("product_group_portfolios.group_id = ?", group.id).each do |product_group_portfolio|
        total += product_group_portfolio.product.get_allocation_for_group(group, year, allocation_precision)
      end
      return total.round(allocation_precision)
    end
    
    
    # Returns a portfolio's total allocation
    def get_total_allocation(year, allocation_precision)
      total = 0.0
      self.products.uniq.each do |product|
        total += product.get_total_allocation(year, allocation_precision)
      end
      return total.round(allocation_precision)
    end
end
