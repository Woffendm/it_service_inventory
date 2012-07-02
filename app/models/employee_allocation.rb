class EmployeeAllocation < ActiveRecord::Base
  attr_accessible :allocation, :employee_id, :service_id, :employee
  belongs_to :employee
  belongs_to :service
  validate :validate_total_allocation
  
  def validate_total_allocation
    total_allocation = 0
    employee.employee_allocations.each do |an_allocation|
      total_allocation += an_allocation.allocation
    end
    if(total_allocation + allocation > 1)
      errors.add(:allocation, "Your allocation is TOO DAMN HIGH")
    end
  end
end
