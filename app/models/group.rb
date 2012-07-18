# This class stores information related to groups, such as their names and list of associated
#    employees.
#
# Author: Michael Woffendin 
# Copyright:

class Group < ActiveRecord::Base
  attr_accessible :name, :employees
  has_many :employee_groups
  has_many :employees, :through => :employee_groups
  validates_presence_of :name
  
  
  # Returns array of employees not currently in the given group
  def get_available_employees
    Employee.order(:name_last) - self.employees
  end
end