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


  # Stores an array of numbers between and including 0.1 to 1.0
  POSSIBLE_ALLOCATIONS = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]


  # Because mysql is bad at storing floats which aren't a power of 2, before the allocation value 
  # can be used in a display or calculation it must first be rounded to one decimal place. 
  def rounded_allocation
    return allocation.round(1)
  end

end