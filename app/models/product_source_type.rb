# This file is about product source types. A product source type is where a product gets its data
#     from, whether it be an external source or another product. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductSourceType < ActiveRecord::Base
  attr_accessible :name
  has_many :product_sources, :dependent => :delete_all
  validates_presence_of :name
end
