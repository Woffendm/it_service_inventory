class AddSeedIdToSeededTables < ActiveRecord::Migration
  def up
    add_column :fiscal_years, :seed_id, :int
    add_column :product_states, :seed_id, :int
    add_column :product_types, :seed_id, :int
  end
  
  def down
    remove_column :fiscal_years, :seed_id
    remove_column :product_states, :seed_id
    remove_column :product_types, :seed_id
  end
end
