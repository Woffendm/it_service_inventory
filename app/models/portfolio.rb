class Portfolio < ActiveRecord::Base
  attr_accessible :name, :group_id
  validates_presence_of :name, :group_id
  belongs_to :group
  has_and_belongs_to_many :products
end
