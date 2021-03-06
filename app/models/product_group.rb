# == Schema Information
#
# Table name: product_groups
#
#  id         :integer          not null, primary key
#  product_id :integer
#  group_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# This class links together Products and Groups, enabling products to have many groups and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductGroup < ActiveRecord::Base
  attr_accessible :product, :product_id, :group, :group_id
  belongs_to :product
  belongs_to :group
  validates_presence_of :group_id, :product_id
  validates_uniqueness_of :group_id, :scope => :product_id
  before_destroy :remove_associated_product_group_portfolios
  
  
  
  private
  
  # Removes all ProductGroupPortfolios associated with this GroupPortfolio's product and portfolio
  def remove_associated_product_group_portfolios
    ProductGroupPortfolio.where(:product_id => self.product_id, :group_id => self.group_id).each do |pgp|
      pgp.destroy
    end
    return true
  end

end
