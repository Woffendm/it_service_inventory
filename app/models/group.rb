# This class stores information related to groups, such as their names and list of associated
#    employees.
#
# Author: Michael Woffendin 
# Copyright:

class Group < ActiveRecord::Base
  attr_accessible :name, :employees
  has_many :employee_groups, :dependent => :delete_all
  has_many :employees, :through => :employee_groups
  validates_presence_of :name
  
  
  # Adds the given employee to the group
  def add_employee_to_group(employee)
    self.employees << employee
  end
  
  
  # Gives the selected employee administrative abilities for the group
  def add_group_admin(employee_id)
    temp = self.employee_groups.find_by_employee_id(employee_id)
    temp.group_admin = true
    temp.save
  end
  
  
  # Returns array of employees not currently in the given group
  def get_available_employees
    Employee.order(:name_last) - self.employees
  end
  
  
  # Removes the given employee from the group
  def remove_employee_from_group(employee)
    self.employees.delete(employee)
  end
end