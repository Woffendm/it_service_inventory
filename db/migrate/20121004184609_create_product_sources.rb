class CreateProductSources < ActiveRecord::Migration
  def change
    create_table :product_sources do |t|
      t.string :title
      t.string :url
      t.integer :product_id
      t.integer :product_source_type_id
      t.timestamps
    end
  end
end
