class Portfolio < ActiveRecord::Base
  attr_accessible :portfolio_name_id, :group_id, :portfolio_products, :portfolio_products_attributes
  validates_presence_of :portfolio_name_id, :group_id
  belongs_to :group
  belongs_to :portfolio_name
  has_many :portfolio_products, :dependent => :delete_all
  has_many :products, :through => :portfolio_products
  accepts_nested_attributes_for :portfolio_products,  :allow_destroy => true
  delegate :name, :to => :portfolio_name, :allow_nil => true
  validate :group_does_not_have_this_portfolio_multiple_times
  
  
  # Checks to see if there is a portfolio with the same portfolio name and group as the one 
  # being saved. Cancels save if there is one, and it is not the current portfolio being saved. 
  # The second check is done for updating.
  def group_does_not_have_this_portfolio_multiple_times
    portfolio = Portfolio.where(:group_id => group_id, 
                :portfolio_name_id => portfolio_name_id).first
    if portfolio && self != portfolio
      errors.add :group_id, "This group already has a portfolio with this name" 
    end
  end
end
