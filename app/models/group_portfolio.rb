# This class links together Products and Groups, enabling products to have many groups and 
#   visa versa. 
#
# Author: Michael Woffendin 
# Copyright:
class GroupPortfolio < ActiveRecord::Base
  attr_accessible :group, :group_id, :portfolio, :portfolio_id
  belongs_to :group
  belongs_to :portfolio
  validates_presence_of   :portfolio_id, :group_id
  validates_uniqueness_of :group_id, :scope => :portfolio_id
  before_destroy :remove_associated_product_groups
  
  
  # Removes all ProductGroups associated with this GroupPortfolio's group and portfolio
  def remove_associated_product_groups
    ProductGroup.where(:group_id => self.group_id, :portfolio_id => self.portfolio_id).each do |pg|
      pg.destroy
    end
  end
end
