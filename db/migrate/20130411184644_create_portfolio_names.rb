class CreatePortfolioNames < ActiveRecord::Migration
  def up
    create_table :portfolio_names do |t|
      t.string  :name
      t.boolean :global
      t.timestamps
    end
    remove_column :portfolios,  :name
    add_column     :portfolios, :portfolio_name_id, :integer
  end
  
  
  def down
    drop_table        :portfolio_names
    add_column        :portfolios, :name, :string
    remove_column     :portfolios, :portfolio_name_id
  end
end
