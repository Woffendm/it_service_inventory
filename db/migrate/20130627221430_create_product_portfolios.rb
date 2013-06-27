class CreateProductPortfolios < ActiveRecord::Migration
  def change
    create_table :product_portfolios do |t|
      t.integer :portfolio_id
      t.integer :product_id
      t.timestamps
    end
  end
end
