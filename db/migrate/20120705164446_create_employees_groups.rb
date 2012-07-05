class CreateEmployeesGroups < ActiveRecord::Migration
  def change
    create_table :employees_groups do |t|
      t.integer :employee_id
      t.integer :group_id
    end
  end
end
