class CreateProductServices < ActiveRecord::Migration
  def change
    create_table :product_services do |t|
      t.integer :product_id
      t.integer :service_id

      t.timestamps
    end
  end
end
