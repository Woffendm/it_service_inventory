# This class stores information related to employees such as their names, groups, emails, etc.
#
# Author: Michael Woffendin 
# Copyright:

class Employee < ActiveRecord::Base
  attr_accessible :email, :employee_allocations_attributes, :employee_groups_attributes,
                  :name_first, :name_last, :notes, :preferred_language, :preferred_theme
  has_many :employee_allocations, :dependent => :delete_all
  has_many :employee_groups, :dependent => :delete_all
  has_many :groups, :through => :employee_groups
  has_many :services, :through => :employee_allocations
  validates_presence_of :name_first, :name_last
  validates_uniqueness_of :osu_username, :scope => :osu_id
  accepts_nested_attributes_for :employee_allocations, :allow_destroy => true
  accepts_nested_attributes_for :employee_groups, :allow_destroy => true

  
  # Returns an array of services that the employee does not currently have
  def get_available_services
    Service.order(:name) - self.services
  end
  
  
  # Returns an array of groups that the employee does not currently have
  def get_available_groups
    Group.order(:name) - self.groups
  end
  
  
  # Returns the employee's full name, in the format "lastname, firstname"
  def full_name
    return "#{name_last}, #{name_first}"
  end
end