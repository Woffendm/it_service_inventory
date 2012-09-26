# This class links together Employees and Products, enabling employees to have many products and 
#   visa versa
#
# Author: Michael Woffendin 
# Copyright:

class EmployeeProduct < ActiveRecord::Base
  attr_accessible :allocation, :employee_id, :product_id
  belongs_to :employee
  belongs_to :product
  validates_presence_of :employee_id, :product_id



  # Generates an array of floats between 0.0 and 1.00 inclusive. Incrementation determined by app
  # settings. Each entry in the array contains a formatted decimal for the user's visual pleausure
  # along with a non-formatted decimal for the actual value.
  def self.possible_allocations
    array_of_floats = []
    allocation_precision = AppSetting.get_allocation_precision
    upper_bound_of_incrementation = 1
    for i in 1..allocation_precision
      upper_bound_of_incrementation = upper_bound_of_incrementation * 10
    end
    (0..upper_bound_of_incrementation).each do |integer|
      array_of_floats << ["%.#{allocation_precision}f" % 
                          (integer.to_f / upper_bound_of_incrementation),
                          (integer.to_f / upper_bound_of_incrementation)]
    end
    return array_of_floats
  end



  # Because mysql is bad at storing floats which aren't a power of 2, before the allocation value 
  # can be used in a display or calculation it must first be rounded to two decimal places. 
  def rounded_allocation
    if allocation
      return allocation.round(AppSetting.get_allocation_precision)
    end
  end
end