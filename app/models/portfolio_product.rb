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

end