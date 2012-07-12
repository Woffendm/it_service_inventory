# This class links together Employees and Services.
#
# Author: Michael Woffendin 
# Copyright:

class EmployeeAllocation < ActiveRecord::Base
  attr_accessible :allocation, :employee_id, :service_id, :employee
  belongs_to :employee
  belongs_to :service
  validate :validate_total_allocation
  
  
  # Returns an error message if an employee's total allocation exceeds 1
  def validate_total_allocation
    total_allocation = 0
    employee.employee_allocations.each do |an_allocation|
      total_allocation += an_allocation.allocation
    end
    if(total_allocation + allocation > 1)
      errors.add(:allocation, "total cannot exceed 1")
    end
  end
end
