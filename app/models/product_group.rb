# This class links together Products and Groups, enabling products to have many groups and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductGroup < ActiveRecord::Base
  attr_accessible :product, :product_id, :group, :group_id
  belongs_to :product
  belongs_to :group
  validates_presence_of :product_id, :group_id
  
end
