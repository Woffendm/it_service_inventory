class AddYearToAllocations < ActiveRecord::Migration
  def up
    add_column :employee_products, :fiscal_year_id, :int
    add_column :employee_allocations, :fiscal_year_id, :int
  end
  
  def down
    remove_column :employee_products, :fiscal_year_id
    remove_column :employee_allocations, :fiscal_year_id
  end
end
