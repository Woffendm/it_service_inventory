class Portfolio < ActiveRecord::Base
  attr_accessible :name, :group_id, :portfolio_products, :portfolio_products_attributes
  validates_presence_of :name, :group_id
  belongs_to :group
  has_many :portfolio_products, :dependent => :delete_all
  has_many :products, :through => :portfolio_products
  accepts_nested_attributes_for :portfolio_products,  :allow_destroy => true
  
end
