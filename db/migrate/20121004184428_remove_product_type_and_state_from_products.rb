class RemoveProductTypeAndStateFromProducts < ActiveRecord::Migration
  def up
    remove_column :products, :product_state
    remove_column :products, :product_type
  end
  def down
    add_column :products, :product_state, :string
    add_column :products, :product_type, :string
  end
end
