# == Schema Information
#
# Table name: employee_products
#
#  id             :integer          not null, primary key
#  product_id     :integer
#  employee_id    :integer
#  allocation     :float
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fiscal_year_id :integer
#

# This class links together Employees and Products, enabling employees to have many products and 
#   visa versa
#
# Author: Michael Woffendin 
# Copyright:

class EmployeeProduct < ActiveRecord::Base
  attr_accessible :allocation, :employee_id, :product_id, :fiscal_year_id
  belongs_to :employee
  belongs_to :product
  belongs_to :fiscal_year
  validates_presence_of :employee_id, :product_id, :fiscal_year_id
  validates_uniqueness_of :employee_id, :scope => [:fiscal_year_id, :product_id]
  validates_uniqueness_of :product_id, :scope => [:fiscal_year_id, :employee_id]
  validates_uniqueness_of :fiscal_year_id, :scope => [:employee_id, :product_id]
  validate :validate_allocation
  delegate :name, :to => :product


  # Validates that the allocation is within proper range
  def validate_allocation
    unless allocation.blank?
      unless (allocation >= 0) && (allocation <= 1)
        errors.add(:allocation, "Allocation must be between 0 and 1 FTE")
      end
    end
  end


  # Generates an array of floats between 0.0 and 1.00 inclusive. Incrementation determined by app
  # settings. Each entry in the array contains a formatted decimal for the user's visual pleausure
  # along with a non-formatted decimal for the actual value.
  def self.possible_allocations(allocation_precision)
    array_of_floats = []
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
  def rounded_allocation(allocation_precision)
    return allocation.round(allocation_precision) if allocation
    return 0.0
  end
end
