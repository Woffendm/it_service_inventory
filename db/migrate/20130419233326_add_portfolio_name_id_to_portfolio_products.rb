class AddPortfolioNameIdToPortfolioProducts < ActiveRecord::Migration
  def up
    add_column    :portfolio_products, :portfolio_name_id, :integer
  end
  
  def down
    remove_column :portfolio_products, :portfolio_name_id
  end
end
