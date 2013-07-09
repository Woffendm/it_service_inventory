class RemoveProductSources < ActiveRecord::Migration
  def up
    drop_table :product_sources
    drop_table :product_source_types
  end



  def down
    create_table :product_sources do |t|
      t.string :title
      t.string :url
      t.integer :product_id
      t.integer :product_source_type_id
      t.timestamps
    end
    
    create_table :product_source_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
