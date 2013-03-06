class AddPriorityToProducts < ActiveRecord::Migration
  def up
    add_column :products, :product_priority_id, :integer
  end
  def down
    remove_column :products, :product_priority_id
  end
end
