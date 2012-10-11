# This file links together products and product source types. It also provides a url field, which 
#     is a url to the product source rather than the product itself. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductSource < ActiveRecord::Base
  attr_accessible :product, :product_id, :product_source_type, :product_source_type_id, :title, :url
  belongs_to :product
  belongs_to :product_source_type
  validates_presence_of :product_id, :product_source_type_id, :title
end
