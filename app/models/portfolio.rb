class Portfolio < ActiveRecord::Base
    attr_accessible :name, :global, :product_groups, :product_groups_attributes
    has_many :product_groups,     :dependent => :delete_all
    has_many :products,           :through => :product_groups
    has_many :groups,             :through => :product_groups
    accepts_nested_attributes_for :product_groups,  :allow_destroy => true
    validates_presence_of   :name
    validates_uniqueness_of :name


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
