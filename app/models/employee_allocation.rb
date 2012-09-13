# This class links together Employees and Services, enabling employees to have many services and 
#   visa versa
#
# Author: Michael Woffendin 
# Copyright:

class EmployeeAllocation < ActiveRecord::Base
  attr_accessible :allocation, :employee, :employee_id, :service_id
  belongs_to :employee
  belongs_to :service
  validates_presence_of :allocation, :employee_id, :service_id



  # Generates an array of floats between 0.1 and 1.00 inclusive, incrementing by 0.1. 
  def possible_allocations
    array_of_floats = []
    upper_bound_of_incrementation = 1
    for i in 1..AppSetting.first.allocation_precision
      upper_bound_of_incrementation = upper_bound_of_incrementation * 10
    end
    (1..upper_bound_of_incrementation).each do |integer|
      array_of_floats << (integer.to_f / upper_bound_of_incrementation)
    end
    return array_of_floats
  end



  # Because mysql is bad at storing floats which aren't a power of 2, before the allocation value 
  # can be used in a display or calculation it must first be rounded to two decimal places. 
  def rounded_allocation
    return allocation.round(AppSetting.first.allocation_precision)
  end

end