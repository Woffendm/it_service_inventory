# This class stores information related to services, such as their names, related employees, etc.
#
# Author: Michael Woffendin 
# Copyright:

class Service < ActiveRecord::Base
  attr_accessible :name
  has_many :employee_allocations, :dependent => :delete_all
  has_many :employees, :through => :employee_allocations
  validates_presence_of :name
  
  
  # Returns an array of groups that employees with this service have. The array is sorted by the
  # groups' names, and does not contain duplicates. 
  def groups
    array_of_groups = self.employees.collect{ |employee| 
      employee.groups
    }.flatten.uniq
    return array_of_groups.sort_by &:name
  end
  
  
  # Returns a floating point value rounded to one decimal representing the total allocation for this 
  # service within a given group
  #def total_allocation_for_each_group
  #  total_allocation = 0.0
  #  self.employees.each do |employee|
  #    if employee.groups.index(group)
  #      total_allocation += self.employee_allocations.find_by_employee_id(employee.id).allocation
  #    end
  #  end
  #  return total_allocation.round(1)
  #end
  
  
  # Returns a floating point value rounded to one decimal representing the total allocation for this 
  # service within a given group
  def total_allocation_within_group(group)
    total_allocation = 0.0
    self.employees.each do |employee|
      if employee.groups.index(group)
        total_allocation += self.employee_allocations.find_by_employee_id(employee.id).allocation
      end
    end
    return [self.name, total_allocation.round(1)]
  end
end
