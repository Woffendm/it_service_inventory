class CreateProductDependencies < ActiveRecord::Migration
  def change
    create_table :products_products do |t|
      t.integer   :dependent_id
      t.integer   :dependency_id
      t.timestamps
    end
  end
end
