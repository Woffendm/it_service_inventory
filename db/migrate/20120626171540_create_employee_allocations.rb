class CreateEmployeeAllocations < ActiveRecord::Migration
  def change
    create_table :employee_allocations do |t|
      t.integer :employee_id
      t.integer :service_id
      t.float :allocation

      t.timestamps
    end
  end
end
