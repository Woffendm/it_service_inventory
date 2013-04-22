class PortfolioName < ActiveRecord::Base
  attr_accessible :name, :global, :portfolio_products, :portfolio_products_attributes
  has_many :portfolios
  has_many :portfolio_products, :dependent => :delete_all
  has_many :products, :through => :portfolio_products
  accepts_nested_attributes_for :portfolio_products,  :allow_destroy => true
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  
  # Returns all groups which have assigned this product to this portfolio. 
  def groups_for_product(product)
    Group.joins(:portfolios => :portfolio_products).where(
        :portfolio_products => {:portfolio_name_id => self.id, :product_id => product.id})
  end
end
