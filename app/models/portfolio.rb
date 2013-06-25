class Portfolio < ActiveRecord::Base
    attr_accessible :name, :global, :product_groups, :product_groups_attributes
    has_many :product_groups,     :dependent => :delete_all
    has_many :products,           :through => :product_groups
    has_many :groups,             :through => :product_groups
    accepts_nested_attributes_for :product_groups,  :allow_destroy => true
    validates_presence_of   :name
    validates_uniqueness_of :name



    # Returns all global portfolio names
    def self.global_portfolios
      return Portfolio.where(:global => true).order(:name)
    end
end
