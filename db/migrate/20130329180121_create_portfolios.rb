class CreatePortfolios < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.string :name
      t.integer :group_id

      t.timestamps
    end
  end
end
