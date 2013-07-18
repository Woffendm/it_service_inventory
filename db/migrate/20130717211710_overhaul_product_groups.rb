class OverhaulProductGroups < ActiveRecord::Migration
  def up
    rename_table :product_groups, :product_group_portfolios
    create_table :product_groups do |t|
      t.integer :group_id
      t.integer :product_id
      t.timestamps
    end
    remove_column :portfolios, :global
    # Creates private portfolio for each existing group
    Group.all.each do |group|
      # Assigns all product_groups without a portfolio to the private portfolio
      ProductGroupPortfolio.where(:group_id => group.id, :portfolio_id => nil).each do |pgp|
        ProductGroup.create(:product_id => pgp.product_id, :group_id => group.id)
      end
    end
  end

  def down
    drop_table :product_groups
    rename_table :product_groups_portfolios, :product_groups
    add_column :portfolios, :global, :boolean
  end
end
