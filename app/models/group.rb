class Group < ActiveRecord::Base
  attr_accessible :name, :employees
  has_and_belongs_to_many :employees
  validates_presence_of :name
  
  
  # Returns array of employees not currently in the given group
  def get_available_employees
    Employee.order(:name) - self.employees
  end
end