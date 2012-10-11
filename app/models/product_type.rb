# Stores information about product types. Product types represent who the product was made for, such
#     as Vendor, Custom Developed, Open Source, etc. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductType < ActiveRecord::Base
  attr_accessible :name
  has_many :products
  validates_presence_of :name
end
