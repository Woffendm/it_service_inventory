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
  # groups" names, and does not contain duplicates. 
  def groups
    array_of_groups = self.employees.collect{ |employee| 
      employee.groups
    }.flatten.uniq
    return array_of_groups.sort_by &:name
  end


  #
  def get_total_allocation
    total_allocation = 0.0
    self.employee_allocations.each do |employee_allocation|
      total_allocation += employee_allocation.rounded_allocation
    end
    return total_allocation
  end


  # Returns multiple nested arrays. The innermost nested array contains the full names of all
  # the employees who both posess this service and belong to the given group, and the corresponding
  # allocations that those employees have for this service. The allocation values are rounded to 
  # one decimal.
  def employee_allocations_within_group(group)
    array_of_employees_with_service_within_group = []
    self.employees.each do |employee|
      if employee.groups.index(group)
        array_of_employees_with_service_within_group << employee
      end
    end
    array_of_employees_and_allocations = []
    array_of_employees_with_service_within_group.each do |employee|
      array_of_employees_and_allocations << ["'#{employee.full_name}'", self.employee_allocations.find_by_employee_id(employee.id).allocation.round(1), 'null']
    end
    return array_of_employees_and_allocations    
  end


  # Returns an array which contains the name of the given group, and the total allocation for this
  # service within the given group. The total allocation is rounded to one decimal.
  def total_allocation_for_group(group)
    total_allocation = 0.0
    total_headcount = 0.0
    self.employees.each do |employee|
      if employee.groups.index(group)
        total_allocation += self.employee_allocations.find_by_employee_id(employee.id).allocation
        total_headcount += 1
      end
    end
    return ["'#{group.name}'", total_allocation.round(1), total_headcount]
  end


  # Returns an array which contains the name of this service, and the total allocation for this
  # service within the given group. The total allocation is rounded to one decimal.
  def total_allocation_within_group(group)
    total_allocation = 0.0
    total_headcount = 0.0
    self.employees.each do |employee|
      if employee.groups.index(group)
        total_allocation += self.employee_allocations.find_by_employee_id(employee.id).allocation
        total_headcount += 1
      end
    end
    return ["'#{self.name}'", total_allocation.round(1), total_headcount]
  end
end
