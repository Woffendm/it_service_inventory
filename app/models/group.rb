# This class stores information related to groups, such as their names and list of associated
#    employees.
#
# Author: Michael Woffendin 
# Copyright:

class Group < ActiveRecord::Base
  attr_accessible :employees, :name
  has_many :employee_groups, :dependent => :delete_all
  has_many :employees, :through => :employee_groups
  validates_presence_of :name
  
  
  # Adds the given employee to the group
  def add_employee_to_group(employee)
    self.employees << employee
  end
  
  
  # Returns array of employees not currently in the given group
  def get_available_employees
    Employee.order(:name_last) - self.employees
  end
  
  
  # Returns the total the total allocation for the group. This is defined as the sum of the total
  # allocations for every employee in the group 
  def get_total_allocation
    total_allocation = 0.0
    self.employees.each do |employee|
      total_allocation += employee.get_total_allocation
    end
    return total_allocation
  end
  
  
  # Removes the given employee from the group
  def remove_employee_from_group(employee)
    self.employees.delete(employee)
  end
  
  
  # Returns an array of services that the employees of the group have. The array is sorted by the
  # services' names, and does not contain duplicates. 
  def services
    array_of_services = self.employees.collect{ |employee| 
      employee.services
    }.flatten.uniq
    return array_of_services.sort_by &:name
  end
end