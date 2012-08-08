# This class links together Employees and Services, enabling employees to have many services and 
#   visa versa
#
# Author: Michael Woffendin 
# Copyright:

class EmployeeAllocation < ActiveRecord::Base
  attr_accessible :allocation, :employee_id, :service_id, :employee
  belongs_to :employee
  belongs_to :service
  validates_presence_of :employee_id, :service_id


  # Because mysql is bad at storing floats which aren't a power of 2, before the allocation value 
  # can be used in a display or calculation it must first be rounded to one decimal place. 
  def rounded_allocation
    return allocation.round(1)
  end

end