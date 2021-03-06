# == Schema Information
#
# Table name: product_priorities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Stores information about product priorities. Product priorities represent the importance of a 
#     product. (1, 2, 3... High, Low, etc.)
#
# Author: Michael Woffendin 
# Copyright:
class ProductPriority < ActiveRecord::Base
    attr_accessible :name
    has_many :products
    validates_presence_of   :name
    validates_uniqueness_of :name
end
