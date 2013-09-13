# == Schema Information
#
# Table name: product_group_portfolios
#
#  id           :integer          not null, primary key
#  group_id     :integer
#  product_id   :integer
#  portfolio_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# This class links together Products and Groups, enabling products to have many groups and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductGroupPortfolio < ActiveRecord::Base
  attr_accessible :product, :product_id, :group, :group_id, :portfolio, :portfolio_id
  belongs_to :product
  belongs_to :group
  belongs_to :portfolio
  validates_presence_of :product_id, :group_id, :portfolio_id
  validates_uniqueness_of :group_id, :scope => [:product_id, :portfolio_id]
  validates_uniqueness_of :product_id, :scope => [:portfolio_id, :group_id]
  validates_uniqueness_of :portfolio_id, :scope => [:group_id, :product_id]
  after_create :create_group_portfolio
  after_create :create_product_portfolio
  after_create :create_product_group
  
  
  
  private
  
  # Createsa corresponding group portfolio if none exists
  def create_group_portfolio
    GroupPortfolio.create(:portfolio_id => self.portfolio_id, :group_id => self.group_id)
    return true
  end
  
  
  # Createsa corresponding product group if none exists
  def create_product_group
    ProductGroup.create(:group_id => self.group_id, :product_id => self.product_id)
    return true
  end
  
  
  # Createsa corresponding product portfolio if none exists
  def create_product_portfolio
    ProductPortfolio.create(:portfolio_id => self.portfolio_id, :product_id => self.product_id)
    return true
  end
end
