# 
# 
#
# Author: Michael Woffendin 
# Copyright:
class ProductSource < ActiveRecord::Base
  attr_accessible :product, :product_id, :product_source_type, :product_source_type_id, :title, :url
  belongs_to :product
  belongs_to :product_source_type
  validates_presence_of :product_id, :product_source_type_id, :title
end
