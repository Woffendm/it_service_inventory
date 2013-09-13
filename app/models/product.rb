# == Schema Information
#
# Table name: products
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  description         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  url                 :string(255)
#  product_state_id    :integer
#  product_type_id     :integer
#  product_priority_id :integer
#

# This class stores information related to products, such as their names, description, related
#    employees, etc. 
#
# Author: Michael Woffendin 
# Copyright:

class Product < ActiveRecord::Base
  attr_accessible :name, :description, :url, :product_type_id, :product_type, :product_state_id, 
                  :employee_products_attributes, :product_services_attributes,
                  :product_group_portfolios_attributes, :product_priority_id, 
                  :product_portfolios_attributes, :product_groups_attributes


  has_many  :employee_products,  
            :dependent => :delete_all
  has_many  :product_group_portfolios,     
            :dependent => :delete_all
  has_many  :product_groups,     
            :dependent => :delete_all
  has_many  :product_portfolios, 
            :dependent => :delete_all
  has_many  :product_services,   
            :dependent => :delete_all
            
            
  has_many  :employees,          
            :through => :employee_products
  has_many  :groups,             
            :through => :product_groups
  has_many  :portfolios,   
            :through => :product_portfolios
  has_many  :services,   
            :through => :product_services


  has_and_belongs_to_many :dependents, 
      :class_name => "Product", 
      :foreign_key => :dependency_id,   
      :association_foreign_key => :dependent_id 
  has_and_belongs_to_many :dependencies, 
      :class_name => "Product", 
      :foreign_key => :dependent_id,
      :association_foreign_key => :dependency_id
      
      
  belongs_to :product_type
  belongs_to :product_state
  belongs_to :product_priority
  
  
  before_validation :smart_add_url_protocol
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  
  accepts_nested_attributes_for :employee_products, 
      :allow_destroy => true
  accepts_nested_attributes_for :product_services,  
      :allow_destroy => true
  accepts_nested_attributes_for :product_group_portfolios,    
      :allow_destroy => true
  accepts_nested_attributes_for :product_groups,    
      :allow_destroy => true
  
  
  
  
  # Returns the name of the product type if the product type isn't nil
  def type
    unless self.product_type.nil?
      return self.product_type.name
    end
  end
  
  
  # Returns the name of the product state if the product state isn't nil
  def state
    unless self.product_state.nil?
      return self.product_state.name
    end
  end
  
  
  # Returns the name of the product state if the product state isn't nil
  def priority
    unless self.product_priority.nil?
      return self.product_priority.name
    end
  end
  
  
  # Returns an array of all an product's employee product objects for a given year
  def get_allocations_for_year(year)
    self.employee_products.where(:fiscal_year_id => year.id)
  end
  
  
  # Returns the sum of all the allocations for this service by employees in the given group for the 
  # given year. 
  def get_allocation_for_group(group, year, allocation_precision)
    allocation_sum = 0.0
    EmployeeProduct.joins(:employee => :groups
                     ).where(:product_id => self.id, :fiscal_year_id => year.id, 
                             :groups => {:id => group.id}
                     ).each do |employee_allocation|
      allocation_sum += employee_allocation.allocation if employee_allocation.allocation
    end
    return allocation_sum.round(allocation_precision)
  end
  
  
  # Returns an array of services that the product does not currently have
  def get_available_services
    Service.order(:name) - self.services
  end


  # Returns an array of employees that the product does not currently have for the given fiscal year
  def get_available_employees(year)
    current_employees = self.get_allocations_for_year(year).pluck(:employee_id)
    current_employees = [0] if current_employees.blank?
    Employee.active_employees.where("id NOT IN (?)", current_employees)
  end


  # Returns an array of groups that the product does not currently have
  def get_available_groups
    Group.order(:name) - self.groups
  end


  # Returns all portfolios which this product does not currently belong to
  def get_available_portfolios
    Portfolio.order(:name) - self.portfolios
  end


  # Returns the total allocation for the given product.
  def get_total_allocation(year, allocation_precision)
    total_allocation = 0.0
    self.employee_products.where(:fiscal_year_id => year.id).each do |employee_product|
      total_allocation += employee_product.allocation unless employee_product.allocation.blank?
    end
    return total_allocation.round(allocation_precision)
  end
  
  
  # Returns an EmployeeProduct object which has a product_id matching this product's id and an
  # employee_id matching the given employee's id
  def get_employee_product(employee, year)
   self.employee_products.where(:employee_id => employee.id, :fiscal_year_id => year.id) 
  end
  
  
  # All the following (before private) involve rest services
    # Creates hash representation of product's employees for REST services
    def rest_employees
      employee_array = []
      self.employees.uniq.each do |employee|
        employee_array << {"id" => employee.id, "first_name" => employee.first_name, "last_name" => employee.last_name}
      end
      return employee_array
    end
    
    
    # Creates hash representation of product's groups for REST services
    def rest_groups
      group_array = []
      self.groups.uniq.each do |group|
        group_array << {"id" => group.id, "name" => group.name}
      end
      return group_array
    end
    
    
    # Creates hash representation of product's services for REST services
    def rest_services
      service_array = []
      self.services.uniq.each do |service|
        service_array << {"id" => service.id, "name" => service.name}
      end
      return service_array
    end
    
    
    # Creates hash representation of product for REST services
    def rest_show 
      {
        "id" => self.id, 
        "name" => self.name,
        "description" => self.description, 
        "product_priority" => {
          "id" => self.product_priority_id, 
          "name" => self.priority
        }, 
        "product_type" => {
          "id" => self.product_type_id, 
          "name" => self.type
        },
        "product_state" => {
          "id" => self.product_state_id, 
          "name" => self.state
        }, 
        "groups" => self.rest_groups, 
        "services" => self.rest_services,
        "employees" => self.rest_employees
      }
    end
  
  
    # Creates array of all products in hash form for REST services
    def self.rest_show_all
      array = []
      Product.order(:name).each do |product|
        array << product.rest_show
      end
      return array
    end
  
  
  private
    # Checks to see if the url has an http:// or https:// and prepends it if it doesn't
    def smart_add_url_protocol
      unless self.url.blank? || self.url.index("https://") || self.url.index("http://")
        self.url = "http://" + self.url
      end
    end
end
