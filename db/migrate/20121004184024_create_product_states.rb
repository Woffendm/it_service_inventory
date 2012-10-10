class CreateProductStates < ActiveRecord::Migration
  def change
    create_table :product_states do |t|
      t.string :name
      t.timestamps
    end
  end
end
