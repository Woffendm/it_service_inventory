# == Schema Information
#
# Table name: employees
#
#  id                 :integer          not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  middle_name        :string(255)
#  email              :string(255)
#  uid                :string(255)
#  osu_id             :string(255)
#  site_admin         :boolean
#  notes              :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  preferred_language :string(255)
#  preferred_theme    :string(255)
#  new_user_reminder  :boolean          default(TRUE)
#  active             :boolean          default(TRUE)
#  ldap_identifier    :string(255)
#

# This class stores information related to employees such as their names, groups, emails, etc.
#
# Author: Michael Woffendin 
# Copyright:

class Employee < ActiveRecord::Base
  attr_accessible :email, :employee_allocations_attributes, :employee_allocations, 
                  :employee_groups_attributes, :uid,
                  :first_name, :last_name, :notes, :preferred_language, :preferred_theme,
                  :new_user_reminder, :employee_products_attributes
  has_many :employee_allocations, :dependent => :delete_all
  has_many :employee_groups,      :dependent => :delete_all
  has_many :employee_products,    :dependent => :delete_all
  has_many :groups,   :through => :employee_groups
  has_many :products, :through => :employee_products
  has_many :services, :through => :employee_allocations
  validates_presence_of   :first_name,    :last_name,   :uid
  validates_uniqueness_of :uid,  :scope => :osu_id
  accepts_nested_attributes_for :employee_allocations,  :allow_destroy => true
  accepts_nested_attributes_for :employee_groups,       :allow_destroy => true
  accepts_nested_attributes_for :employee_products,     :allow_destroy => true



  # Returns all active employees, sorted by both names.
  def self.active_employees
    Employee.where(:active => true).order(:last_name, :first_name)
  end


  # Creates an employee using information gathered from LDAP. Returns the new, unsaved employee 
  def self.ldap_create(uid)
    return nil if Employee.find_by_uid(uid)
    employee_information = RemoteEmployee.find_by_uid(uid)
    return nil if employee_information.blank?
    employee_information = employee_information[0]
    return nil if employee_information.blank?
    # Splits returned string about the ',', separating the last name from the first and middle names
    name = employee_information.cn.first.split(",")
    # Splits the first and middle names around the " " between them. 
    first_and_middle_names = name[1].split(" ")
    # Creates the employee
    new_employee = Employee.new
    new_employee.last_name = name[0]
    new_employee.first_name = first_and_middle_names[0]
    new_employee.middle_name = first_and_middle_names[1]
    new_employee.osu_id = employee_information[:osuuid][0]
    new_employee.uid = uid
    new_employee.email = employee_information[:mail][0].downcase unless employee_information[:mail].blank?
    # Makes them a site admin if they are the first user
    new_employee.site_admin = true if Employee.all.blank? 
    return new_employee
  end


  # Returns all groups where the user is an admin
  def admin_groups
    Group.joins(:employee_groups).where(:employee_groups => {:employee_id => self.id, :group_admin => true}).order(:name)
  end


  # Returns an array of all an employee's employee allocation objects for a given year
  def get_service_allocations(year)
    self.employee_allocations.joins(:service).where(
        :fiscal_year_id => year.id).includes(:service).order(:name)
  end
  
  
  # Returns an array of all an employee's employee product objects for a given year
  def get_product_allocations(year)
    self.employee_products.joins(:product).where(
        :fiscal_year_id => year.id).includes(:product).order(:name)
  end


  # Returns an array of services that the employee does not currently have for the given fiscal year
  def get_available_services(year)
    current_services = self.get_service_allocations(year).pluck(:service_id)
    current_services = [0] if current_services.blank?
    Service.where("id NOT IN (?)", current_services).order(:name)
  end


  # Returns an array of groups that the employee does not currently have
  def get_available_groups
    Group.order(:name) - self.groups
  end


  # Returns an array of products that the employee does not currently have for the given fiscal year
  def get_available_products(year)
    current_products = self.get_product_allocations(year).pluck(:product_id)
    current_products = [0] if current_products.blank?
    Product.where("id NOT IN (?)", current_products).order(:name)
  end


  # Returns the employee's total service allocation for the given fiscal year.
  def get_total_service_allocation(year, allocation_precision)
    total_allocation = 0.0
    self.employee_allocations.where(:fiscal_year_id =>year.id).each do |employee_allocation|
      total_allocation += employee_allocation.allocation
    end
    return total_allocation.round(allocation_precision)
  end
  
  # Returns the employee's total product allocation for the given fiscal year.
  def get_total_product_allocation(year, allocation_precision)
    total_allocation = 0.0
    self.employee_products.where(:fiscal_year_id =>year.id).each do |employee_product|
      total_allocation += employee_product.allocation unless employee_product.allocation.blank?
    end
    return total_allocation.round(allocation_precision)
  end


  # Returns the employee's full name, in the format "lastname, firstname"
  def full_name
    full_name = "#{last_name}, #{first_name}"
    full_name += " (#{I18n.t :inactive})" unless active
    return full_name
  end
end
