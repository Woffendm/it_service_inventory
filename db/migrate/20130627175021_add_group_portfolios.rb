class AddGroupPortfolios < ActiveRecord::Migration
  def change
    create_table :group_portfolios do |t|
      t.integer :portfolio_id
      t.integer :group_id
      t.timestamps
    end
  end
end
