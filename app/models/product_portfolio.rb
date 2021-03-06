# == Schema Information
#
# Table name: product_portfolios
#
#  id           :integer          not null, primary key
#  portfolio_id :integer
#  product_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# This class links together Products and Groups, enabling products to have many products and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductPortfolio < ActiveRecord::Base
  attr_accessible :product, :product_id, :portfolio, :portfolio_id
  belongs_to :product
  belongs_to :portfolio
  validates_presence_of   :portfolio_id, :product_id
  validates_uniqueness_of :product_id, :scope => :portfolio_id
  before_destroy :remove_associated_product_group_portfolios
  
  
  
  private
  
  # Removes all ProductGroupPortfolios associated with this GroupPortfolio's product and portfolio
  def remove_associated_product_group_portfolios
    ProductGroupPortfolio.where(:product_id => self.product_id, :portfolio_id => self.portfolio_id).each do |pgp|
      pgp.destroy
    end
    return true
  end
end
