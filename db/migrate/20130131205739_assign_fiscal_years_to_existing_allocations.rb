class AssignFiscalYearsToExistingAllocations < ActiveRecord::Migration
  def up
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
end
