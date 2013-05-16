# This class links together Portfolios and Products
#
# Author: Michael Woffendin 
# Copyright:

class PortfolioProduct < ActiveRecord::Base
  attr_accessible :portfolio_id, :product_id, :portfolio_name_id
  belongs_to :portfolio
  belongs_to :product
  belongs_to :portfolio_name
  validates_presence_of :product_id, :portfolio_id, :portfolio_name_id
  validates_uniqueness_of :portfolio_id, :scope => [:portfolio_name_id, :product_id]
  validates_uniqueness_of :product_id, :scope => [:portfolio_id, :portfolio_name_id]
  validates_uniqueness_of :portfolio_name_id, :scope => [:portfolio_id, :product_id]

end