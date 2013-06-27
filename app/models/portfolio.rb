class Portfolio < ActiveRecord::Base
    attr_accessible :name, :global, :group_portfolios, :group_portfolios_attributes,
                    :product_groups, :product_groups_attributes
    has_many :product_groups,     :dependent => :delete_all
    has_many :products,           :through => :product_groups
    has_many :group_portfolios,   :dependent => :delete_all
    has_many :groups,             :through => :group_portfolios
    accepts_nested_attributes_for :product_groups,    :allow_destroy => true
    accepts_nested_attributes_for :group_portfolios,  :allow_destroy => true
    validates_presence_of   :name
    validates_uniqueness_of :name


    # Returns all product groups belonging to the given group in this portfolio
    def product_groups_for_group(group)
      ProductGroup.where(:group_id => group.id, :portfolio_id => self.id).includes(:product).order("products.name").uniq
    end


    # Returns all products that the given group does not have in this portfolio
    def possible_products_for_group(group)
      Product.order(:name) - Product.joins(:product_groups).where(:product_groups => {:group_id => group.id, :portfolio_id => self.id}).uniq
    end


    # Returns the group's total product allocation for the given portfolio
    def get_allocation_for_group(group, year, allocation_precision)
      total = 0.0
      self.products.where("product_groups.group_id = ?", group.id).each do |product|
        total += product.get_allocation_for_group(group, year, allocation_precision)
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


    # Returns all global portfolio names
    def self.global_portfolios
      return Portfolio.where(:global => true).order(:name)
    end
end
