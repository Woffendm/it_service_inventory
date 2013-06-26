# This class stores information related to groups, such as their names and list of associated
#    employees.
#
# Author: Michael Woffendin 
# Copyright:

class Group < ActiveRecord::Base
  attr_accessible :employees, :name, :employee_groups,
                  :employee_groups_attributes
  has_many :employee_groups,  :dependent  => :delete_all
  has_many :employees,        :through    => :employee_groups
  has_many :product_groups,   :dependent  => :delete_all
  has_many :products,         :through    => :product_groups
  has_many :portfolios,       :through    => :product_groups
  accepts_nested_attributes_for :portfolios,        :allow_destroy => true
  accepts_nested_attributes_for :employee_groups,   :allow_destroy => true
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  
  # Adds the given employee to the group
  def add_employee_to_group(employee)
    added_employee = self.employee_groups.new
    added_employee.employee_id = employee.id
    added_employee.save
  end
  
  
  # Returns array of employees not currently in the given group
  def get_available_employees
    return Employee.active_employees - self.employees
  end
  
  
  # Returns all products not in the given portfolio for the given group. Products should be an
  # ordered array of products (preferable all of them)
  def get_available_products_for_portfolio(products, portfolio)
    products - Product.joins(:product_groups).where("product_groups.group_id = ? AND product_groups.portfolio_id = ?",  self.id, portfolio.id)
  end
  
  
  # Returns the total the total product allocation for the group. This is defined as the sum of the 
  # total product allocations for every employee in the group 
  def get_total_product_allocation(year, allocation_precision)
    total_allocation = 0.0
    self.products.each do |product| 
      product.employee_products.joins(:employee => :groups).where(
            :fiscal_year_id => year.id, :groups => {:id => self.id}).each do |product_allocation|  
        total_allocation += product_allocation.allocation unless product_allocation.allocation.blank?
      end 
    end
    return total_allocation.round(allocation_precision)
  end
  
  
  # Returns the total the total service allocation for the group. This is defined as the sum of the 
  # total service allocations for every employee in the group
  def get_total_service_allocation(year, allocation_precision)
    total_allocation = 0.0
    self.employees.each do |employee|
      total_allocation += employee.get_total_service_allocation(year, allocation_precision) 
    end
    return total_allocation.round(allocation_precision)
  end
  
  
  # Removes the given employee from the group
  def remove_employee_from_group(employee)
    self.employees.delete(employee)
  end
  
  
  # Returns a table of services that the employees of the group have. The table is sorted by the
  # services' names, and does not contain duplicates. 
  def services(year = nil)
    if year.blank?
      Service.joins(:employees => :groups).where(:groups => {:id => self.id}).uniq.order(:name)
    else
      Service.joins(:employees => :groups).where(:groups => {:id => self.id},
          :employee_allocations => {:fiscal_year_id => year.id}).uniq.order(:name)
    end
  end
end