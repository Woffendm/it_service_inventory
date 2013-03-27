# This class links together Employees and Services, enabling employees to have many services and 
#   visa versa
#
# Author: Michael Woffendin 
# Copyright:

class EmployeeAllocation < ActiveRecord::Base
  attr_accessible :allocation, :employee, :employee_id, :service_id, :fiscal_year_id
  belongs_to :employee
  belongs_to :service
  belongs_to :fiscal_year
  validates_presence_of :allocation, :employee_id, :service_id, :fiscal_year_id
  delegate :name, :to => :service


  # Generates an array of floats between 0.0 and 1.00 inclusive. Incrementation determined by app
  # settings. Each entry in the array contains a formatted decimal for the user's visual pleausure
  # along with a non-formatted decimal for the actual value. 
  def self.possible_allocations(allocation_precision)
    array_of_floats = []
    upper_bound_of_incrementation = 1
    for i in 1..allocation_precision
      upper_bound_of_incrementation = upper_bound_of_incrementation * 10
    end
    (1..upper_bound_of_incrementation).each do |integer|
      array_of_floats << ["%.#{allocation_precision}f" % 
                         (integer.to_f / upper_bound_of_incrementation),
                         (integer.to_f / upper_bound_of_incrementation)]
    end
    return array_of_floats
  end



  # Because mysql is bad at storing floats which aren't a power of 2, before the allocation value 
  # can be used in a display or calculation it must first be rounded to two decimal places. 
  def rounded_allocation(allocation_precision)
    return allocation.round(allocation_precision)
  end

end