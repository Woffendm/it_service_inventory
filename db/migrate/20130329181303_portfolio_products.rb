class PortfolioProducts < ActiveRecord::Migration
  def change
    create_table :portfolio_products do |t|
      t.integer :portfolio_id
      t.integer :product_id
  
      t.timestamps
    end
  end
end
