# This class links together Employees and Services, enabling employees to have many services and 
#   visa versa
#
# Author: Michael Woffendin 
# Copyright:

class EmployeeAllocation < ActiveRecord::Base
  attr_accessible :allocation, :employee_id, :service_id, :employee
  belongs_to :employee
  belongs_to :service
  validate :validate_total_allocation
  
  
  # Because mysql is bad at storing floats which aren't a power of 2, before the allocation value 
  # can be used in a display or calculation it must first be rounded to one decimal place. 
  def rounded_allocation
    return allocation.round(1)
  end
  
  
  # Returns an error message if an employee's total allocation exceeds 1
  def validate_total_allocation
    total_allocation = 0
    employee.employee_allocations.each do |an_allocation|
      total_allocation += an_allocation.rounded_allocation
    end
    if(total_allocation + rounded_allocation > 1)
      errors.add(:allocation, "total cannot exceed 1")
    end
  end
end
