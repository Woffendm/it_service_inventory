# == Schema Information
#
# Table name: product_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  seed_id    :integer
#

# Stores information about product types. Product types represent who the product was made for, such
#     as Vendor, Custom Developed, Open Source, etc. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductType < ActiveRecord::Base
  attr_accessible :name
  has_many :products
  validates_presence_of :name
  validates_uniqueness_of :name
end
