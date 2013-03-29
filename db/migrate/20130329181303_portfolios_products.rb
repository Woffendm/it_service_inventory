class PortfoliosProducts < ActiveRecord::Migration
  def change
    create_table :portfolios_products do |t|
      t.integer :portfolio_id
      t.integer :product_id
  
      t.timestamps
    end
  end
end
