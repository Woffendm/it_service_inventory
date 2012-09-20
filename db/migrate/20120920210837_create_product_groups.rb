class CreateProductGroups < ActiveRecord::Migration
  def change
    create_table :product_groups do |t|
      t.integer :product_id
      t.integer :group_id
      t.timestamps
    end
  end
end
