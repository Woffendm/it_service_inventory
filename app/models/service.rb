# This class stores information related to services, such as their names, related employees, etc.
#
# Author: Michael Woffendin 
# Copyright:

class Service < ActiveRecord::Base
  attr_accessible :name, :description
  has_many :employee_allocations, :dependent  => :delete_all
  has_many :employees,            :through    => :employee_allocations
  has_many :product_services,     :dependent  => :delete_all
  has_many :products,             :through    => :product_services
  validates_presence_of :name


  # Returns an array of groups that employees with this service have. The array is sorted by the
  # groups" names, and does not contain duplicates. 
  def groups(year = 0)
    if year == 0
      Group.joins(:employees => :services).where(:services => {:id => self.id}).uniq.order(:name)
    else
      Group.joins(:employees => :services).where(:services => {:id => self.id}, 
                :employee_allocations => {:fiscal_year_id => year.id} ).uniq.order(:name)
    end
  end


  # Returns the total allocation for this service. This is defined as the sum of every allocation 
  # within this service's employee_allocations array
  def get_total_allocation(year)
    total_allocation = 0.0
    self.employee_allocations.where(:fiscal_year_id => year.id).each do |employee_allocation|
      total_allocation += employee_allocation.rounded_allocation
    end
    return total_allocation
  end


  # Returns an EmployeeAllocation object which has a service_id matching this service's id and an
  # employee_id matching the given employee's id
  def get_employee_allocation(employee, year)
    self.employee_allocations.where(:employee_id => employee.id, :fiscal_year_id => year.id) 
  end


  # Returns the sum of all the allocations for this service by employees in the given group for the 
  # given year. 
  def get_allocation_for_group(group, year)
    allocation_sum = 0.0
    EmployeeAllocation.joins(:employee => :groups
                     ).where(:service_id => self.id, :fiscal_year_id => year.id, 
                             :groups => {:id => group.id}
                     ).each do |employee_allocation|
      allocation_sum += employee_allocation.allocation
    end
    return allocation_sum
  end
  
  
  # Returns multiple nested arrays. The innermost nested array contains the full names of all
  # the employees who both posess this service and belong to the given group, and the corresponding
  # allocations that those employees have for this service. The allocation values are rounded to 
  # one decimal.
  def employee_allocations_within_group(group, year)
    allocation_precision = AppSetting.get_allocation_precision   
    array_of_employees_and_allocations = []
    EmployeeAllocation.joins(:employee => :groups
                     ).where(:service_id => self.id, :fiscal_year_id => year.id, 
                             :groups => {:id => group.id}
                     ).each do |employee_allocation|
      array_of_employees_and_allocations << ["#{employee_allocation.employee.full_name}",   
      employee_allocation.allocation.round(allocation_precision), nil]
    end
    return array_of_employees_and_allocations    
  end


  # Returns an array which contains the name of the given group, and the total allocation for this
  # service within the given group. The total allocation is rounded to one decimal.
  def total_allocation_for_group(group, year)
    allocation_precision = AppSetting.get_allocation_precision
    total_allocation = 0.0
    total_headcount = 0.0
    EmployeeAllocation.joins(:employee => :groups
                     ).where(:service_id => self.id, :fiscal_year_id => year.id, 
                             :groups => {:id => group.id}
                     ).each do |employee_allocation|
      total_allocation += employee_allocation.allocation
      total_headcount += 1
    end
    return ["#{group.name}", total_allocation.round(allocation_precision), total_headcount]
  end


  # Returns an array which contains the name of this service, and the total allocation for this
  # service within the given group. The total allocation is rounded to one decimal.
  def total_allocation_within_group(group, year)
    allocation_precision = AppSetting.get_allocation_precision
    total_allocation = 0.0
    total_headcount = 0.0
    EmployeeAllocation.joins(:employee => :groups
                     ).where(:service_id => self.id, :fiscal_year_id => year.id, 
                             :groups => {:id => group.id}
                     ).each do |employee_allocation|
      total_allocation += employee_allocation.allocation
      total_headcount += 1
    end
    return ["#{self.name}", total_allocation.round(allocation_precision), total_headcount]
  end
end
