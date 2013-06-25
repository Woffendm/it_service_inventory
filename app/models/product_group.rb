# This class links together Products and Groups, enabling products to have many groups and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductGroup < ActiveRecord::Base
  attr_accessible :product, :product_id, :group, :group_id, :portfolio, :portfolio_id
  belongs_to :product
  belongs_to :group
  belongs_to :portfolio
  validates_presence_of :product_id, :group_id
  validates_uniqueness_of :group_id, :scope => [:product_id, :portfolio_id]
  validates_uniqueness_of :product_id, :scope => [:portfolio_id, :group_id]
  validates_uniqueness_of :portfolio_id, :scope => [:group_id, :product_id]
end
