# This class stores information related to products, such as their names, description, related
#    employees, etc. 
#
# Author: Michael Woffendin 
# Copyright:

class Product < ActiveRecord::Base
  attr_accessible :name, :description, :url, :product_type_id, :product_type, :product_state_id, 
                  :product_state, :employee_products_attributes, :product_services_attributes,
                  :product_groups_attributes, :product_source_attributes
  has_many :employee_products,  :dependent => :delete_all
  has_many :employees,          :through =>   :employee_products
  has_many :product_groups,     :dependent => :delete_all
  has_many :groups,             :through =>   :product_groups
  has_many :product_services,   :dependent => :delete_all
  has_many :services,           :through =>   :product_services
  has_one  :product_source
  belongs_to :product_type
  belongs_to :product_state
  validates_presence_of :name
  accepts_nested_attributes_for :employee_products, :allow_destroy => true
  accepts_nested_attributes_for :product_services,  :allow_destroy => true
  accepts_nested_attributes_for :product_groups,    :allow_destroy => true
  
  
  
  # Returns an array of services that the product does not currently have
  def get_available_services
    Service.order(:name) - self.services
  end


  # Returns an array of employees that the product does not currently have
  def get_available_employees
    Employee.order(:name_last, :name_first) - self.employees
  end


  # Returns an array of groups that the product does not currently have
  def get_available_groups
    Group.order(:name) - self.groups
  end


  # Returns the total allocation for the given product.
  def get_total_allocation
    total_allocation = 0.0
    self.employee_products.each do |employee_product|
      total_allocation += employee_product.rounded_allocation
    end
    return total_allocation
  end
  
  
  # Returns an EmployeeProduct object which has a product_id matching this product's id and an
  # employee_id matching the given employee's id
  def get_employee_product(employee)
   self.employee_products.find_by_employee_id(employee.id) 
  end
  
end