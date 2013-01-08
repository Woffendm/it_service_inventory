# This class stores information related to employees such as their names, groups, emails, etc.
#
# Author: Michael Woffendin 
# Copyright:

class Employee < ActiveRecord::Base
  attr_accessible :email, :employee_allocations_attributes, :employee_allocations, 
                  :employee_groups_attributes,
                  :name_first, :name_last, :notes, :preferred_language, :preferred_theme,
                  :new_user_reminder, :employee_products_attributes
  has_many :employee_allocations, :dependent => :delete_all
  has_many :employee_groups,      :dependent => :delete_all
  has_many :employee_products,    :dependent => :delete_all
  has_many :groups,   :through => :employee_groups
  has_many :products, :through => :employee_products
  has_many :services, :through => :employee_allocations
  validates_presence_of   :name_first,    :name_last
  validates_uniqueness_of :osu_username,  :scope => :osu_id
  accepts_nested_attributes_for :employee_allocations,  :allow_destroy => true
  accepts_nested_attributes_for :employee_groups,       :allow_destroy => true
  accepts_nested_attributes_for :employee_products,     :allow_destroy => true



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
  def get_total_service_allocation(year)
    total_allocation = 0.0
    self.employee_allocations.where(:fiscal_year_id =>year.id).each do |employee_allocation|
      total_allocation += employee_allocation.rounded_allocation
    end
    return total_allocation
  end
  
  # Returns the employee's total product allocation for the given fiscal year.
  def get_total_product_allocation(year)
    total_allocation = 0.0
    self.employee_products.where(:fiscal_year_id =>year.id).each do |employee_product|
      total_allocation += employee_product.rounded_allocation
    end
    return total_allocation
  end


  # Returns the employee's full name, in the format "lastname, firstname"
  def full_name
    return "#{name_last}, #{name_first}"
  end
end