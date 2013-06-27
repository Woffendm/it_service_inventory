# This class links together Products and Groups, enabling products to have many groups and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class ProductGroup < ActiveRecord::Base
  attr_accessible :product, :product_id, :group, :group_id, :portfolio, :portfolio_id
  belongs_to :product
  belongs_to :group
  belongs_to :portfolio
  validates_presence_of :product_id, :group_id, :portfolio_id
  validates_uniqueness_of :group_id, :scope => [:product_id, :portfolio_id]
  validates_uniqueness_of :product_id, :scope => [:portfolio_id, :group_id]
  validates_uniqueness_of :portfolio_id, :scope => [:group_id, :product_id]
  after_save :create_group_portfolio
  after_save :create_product_portfolio
  
  
  # Createsa corresponding group portfolio if none exists
  def create_group_portfolio
    if GroupPortfolio.where(:portfolio_id => self.portfolio_id, :group_id => self.group_id).blank?
      GroupPortfolio.create(:portfolio_id => self.portfolio_id, :group_id => self.group_id)
    end
  end
  
  
  # Createsa corresponding product portfolio if none exists
  def create_product_portfolio
    if ProductPortfolio.where(:portfolio_id => self.portfolio_id, :product_id => self.product_id).blank?
      ProductPortfolio.create(:portfolio_id => self.portfolio_id, :product_id => self.product_id)
    end
  end
end
