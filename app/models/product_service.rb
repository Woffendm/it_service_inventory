# This class links together Products and Services, enabling products to have many services and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductService < ActiveRecord::Base
  attr_accessible :product, :product_id, :service, :service_id
  belongs_to :product
  belongs_to :service
  validates_presence_of :product_id, :service_id
  delegate :name, :to => :service, :allow_nil => true, :prefix => true
  delegate :name, :to => :product, :allow_nil => true, :prefix => true
end
