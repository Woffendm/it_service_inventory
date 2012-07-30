# This class stores information related to employees such as their names, groups, emails, etc.
#
# Author: Michael Woffendin 
# Copyright:

class Employee < ActiveRecord::Base
  attr_accessible :name_first, :name_last, :notes, :email, :preferred_theme, :preferred_language
  has_many :employee_groups
  has_many :groups, :through => :employee_groups
  has_many :employee_allocations
  has_many :services, :through => :employee_allocations
  validates_presence_of :name_first, :name_last
  validate :validate_only_one_of_each_employee

  
  # Returns an array of services that the employee does not currently have
  def get_available_services
    Service.order(:name) - self.services
  end
  
  
  # Returns the employee's full name, in the format "lastname, firstname"
  def full_name
    return "#{name_last}, #{name_first}"
  end


  # Returns an error message if someone tries to add an employee to the application when the 
  # employee is already in the application
  def validate_only_one_of_each_employee
    if id.nil?
      if Employee.find_by_osu_id(osu_id) && Employee.find_by_osu_username(osu_username)
        errors.add(:osu_id, "WARNING: Evil clone detected!")
      end
    end
  end
end