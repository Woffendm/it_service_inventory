class Group < ActiveRecord::Base
  attr_accessible :name, :employees
  validates_presence_of :name
  has_many :employees

end
