class PortfolioName < ActiveRecord::Base
  attr_accessible :name, :global, :portfolio_products, :portfolio_products_attributes
  has_many :portfolios
  has_many :portfolio_products, :dependent => :delete_all
  has_many :products, :through => :portfolio_products
  accepts_nested_attributes_for :portfolio_products,  :allow_destroy => true
  validates_presence_of   :name
  validates_uniqueness_of :name
#  validate :unique_global_name
  
  
  # Ensures that the portolio name is unique if it is global. There can be duplicate non-global 
  # portfolio names, so long as they do not share a name with a global one. A single group cannot 
  # have multiple portfolios of the same name.
  def unique_global_name
    errors.add(:name, "Non-global portfolios cannot share names with global portfolios") if PortfolioName.where(:global => true, :name => name).first
  end
  
  
  # Returns all groups which have assigned this product to this portfolio. 
  def groups_for_product(product)
    Group.joins(:portfolios => :portfolio_products).where(
        :portfolio_products => {:portfolio_name_id => self.id, :product_id => product.id})
  end
  
  
  # Returns all global portfolio names
  def self.global_portfolio_names
    return PortfolioName.where(:global => true).order(:name)
  end
end
