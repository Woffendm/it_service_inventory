class Service < ActiveRecord::Base
  attr_accessible :name
  has_many :employee_allocations
  has_many :employees, :through => :employee_allocations
  validates_presence_of :name
end
