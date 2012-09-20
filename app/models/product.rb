class Product < ActiveRecord::Base
  attr_accessible :name, :description, :group_id, :employee_products_attributes, 
                  :product_services_attributes, :product_groups_attributes
  has_many :employee_products,  :dependent => :delete_all
  has_many :employees,          :through =>   :employee_products
  has_many :product_groups,     :dependent => :delete_all
  has_many :groups,             :through =>   :product_groups
  has_many :product_services,   :dependent => :delete_all
  has_many :services,           :through =>   :product_services
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
end