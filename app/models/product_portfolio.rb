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
  before_destroy :remove_associated_product_groups
  
  
  # Removes all ProductGroups associated with this GroupPortfolio's product and portfolio
  def remove_associated_product_groups
    ProductGroup.where(:product_id => self.product_id, :portfolio_id => self.portfolio_id).each do |pg|
      pg.destroy
    end
  end
end
