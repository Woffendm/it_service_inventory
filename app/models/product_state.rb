# Stores information about product states. Product states represent what stage of its lifecycle 
#     a product is in, such as development, production, retired, etc. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductState < ActiveRecord::Base
  attr_accessible :name
  has_many :products
  validates_presence_of :name
  validates_uniqueness_of :name

end
