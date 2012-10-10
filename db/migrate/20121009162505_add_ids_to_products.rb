class AddIdsToProducts < ActiveRecord::Migration
  def up
    add_column :products, :product_state_id, :integer
    add_column :products, :product_type_id, :integer
  end
  def down
    remove_column :product, :product_state_id
    remove_column :product, :product_type_id
  end
end
