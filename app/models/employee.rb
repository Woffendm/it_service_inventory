# This class stores information related to employees.
#
# Author: Michael Woffendin 
# Copyright:

class Employee < ActiveRecord::Base
  attr_accessible :name, :notes, :groups, :email
  has_and_belongs_to_many :groups
  has_many :employee_allocations
  has_many :services, :through => :employee_allocations
  # Validates name presence and that it has at least one letter
  validates_presence_of :name
  validates_format_of :name, :with => /[a-z]/

  
  # Returns an array of services that the employee does not currently have
  def get_available_services
    Service.order(:name) - self.services
  end
end
