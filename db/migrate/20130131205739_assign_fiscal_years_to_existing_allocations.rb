class AssignFiscalYearsToExistingAllocations < ActiveRecord::Migration
  def up
    return unless FiscalYear.respond_to? :all
     
    @current_fiscal_year = AppSetting.get_current_fiscal_year
    EmployeeAllocation.where(:fiscal_year_id => nil).each do |allocation|
      allocation.fiscal_year_id = @current_fiscal_year.id
      allocation.save
    end
    EmployeeProduct.where(:fiscal_year_id => nil).each do |allocation|
      allocation.fiscal_year_id = @current_fiscal_year.id
      allocation.save
    end
  end
  
  def down
    EmployeeAllocation.all.each do |allocation|
      allocation.fiscal_year_id = nil
      allocation.save
    end
    EmployeeProduct.all.each do |allocation|
      allocation.fiscal_year_id = nil
      allocation.save
    end
  end
end
