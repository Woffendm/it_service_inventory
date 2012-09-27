class AddUrlToProducts < ActiveRecord::Migration
  def up
    add_column :products, :url, :string
    add_column :products, :product_state, :string
    add_column :products, :product_type, :string
  end
  def down
    remove_column :products, :url
    remove_column :products, :product_state
    remove_column :products, :product_type
  end
end
