class Portfolio < ActiveRecord::Base
  attr_accessible :portfolio_name_id, :group_id, :portfolio_products, :portfolio_products_attributes
  validates_presence_of :portfolio_name_id, :group_id
  belongs_to :group
  belongs_to :portfolio_name
  has_many :portfolio_products, :dependent => :delete_all
  has_many :products, :through => :portfolio_products
  accepts_nested_attributes_for :portfolio_products,  :allow_destroy => true
  delegate :name, :to => :portfolio_name, :allow_nil => true
  
  validate :no_group_has_this_portfolio_multiple_times
  
  def no_group_has_this_portfolio_multiple_times
    errors.add :group_id, "This group already has a portfolio with this name" if Portfolio.where(:group_id => group_id, :portfolio_name_id => portfolio_name_id).first
  end
end
