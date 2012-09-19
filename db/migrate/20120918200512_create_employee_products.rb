class CreateEmployeeProducts < ActiveRecord::Migration
  def change
    create_table :employee_products do |t|
      t.integer :product_id
      t.integer :employee_id
      t.float   :allocation
      t.timestamps
    end
  end
end
