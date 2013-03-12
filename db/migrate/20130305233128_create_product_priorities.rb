class CreateProductPriorities < ActiveRecord::Migration
  def change
    create_table :product_priorities do |t|
      t.string :name
      t.timestamps
    end
  end
end
