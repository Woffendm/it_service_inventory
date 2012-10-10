class CreateProductSourceTypes < ActiveRecord::Migration
  def change
    create_table :product_source_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
