# Fiscal years are used to keep track of employee allocations over time. They may be used for other
#   purposes as well in the future.
#
# Author: Michael Woffendin 
# Copyright:

class FiscalYear < ActiveRecord::Base
  attr_accessible :year, :active
  has_many :employee_allocations
  has_many :employee_products
  validates_presence_of :year
  validates_uniqueness_of :year


 # Returns all active fiscal years.
  def self.active_fiscal_years
    return FiscalYear.where(:active => true).order(:year)
  end
  
  def self.rescue_allocations
    if FiscalYear.first.blank?
      @year = FiscalYear.create(:year => 9999)
    else
      @year = FiscalYear.first
    end
    #AppSetting.find_by_code("current_fiscal_year").update_attributes(:value => @year.year)
    EmployeeAllocation.where(:fiscal_year_id => nil).each do |allocation|
      allocation.fiscal_year_id = @year.id
      allocation.save
    end
    EmployeeProduct.where(:fiscal_year_id => nil).each do |allocation|
      allocation.fiscal_year_id = @year.id
      allocation.save
    end
  end
end