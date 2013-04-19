class PortfolioName < ActiveRecord::Base
  attr_accessible :name, :global, :portfolio_products, :portfolio_products_attributes
  has_many :portfolios
  has_many :portfolio_products, :dependent => :delete_all
  has_many :products, :through => :portfolio_products
  accepts_nested_attributes_for :portfolio_products,  :allow_destroy => true
  validates_presence_of   :name
  validates_uniqueness_of :name
end
