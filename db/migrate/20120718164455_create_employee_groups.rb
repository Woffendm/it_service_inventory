class CreateEmployeeGroups < ActiveRecord::Migration
  def change
    create_table :employee_groups do |t|
      t.integer :employee_id
      t.integer :group_id
      t.boolean :group_admin

      t.timestamps
    end
  end
end
