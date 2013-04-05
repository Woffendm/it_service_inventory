# This class links together Portfolios and Products
#
# Author: Michael Woffendin 
# Copyright:

class PortfolioProduct < ActiveRecord::Base
  attr_accessible :portfolio_id, :product_id
  belongs_to :portfolio
  belongs_to :product
  validates_presence_of :product_id, :portfolio_id

end