# 
# 
#
# Author: Michael Woffendin 
# Copyright:
class ProductSourceType < ActiveRecord::Base
  attr_accessible :name
  has_many :product_sources, :dependent => :delete_all
  validates_presence_of :name
end
