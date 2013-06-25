class OverhaulPortfolios < ActiveRecord::Migration
  def up
    add_column      :product_groups, :portfolio_id, :integer
    PortfolioProduct.all.each do |pp|
      pg = ProductGroup.where(:group_id => pp.portfolio.group_id, :product_id => pp.product_id).first
      unless pg.blank?
        pg.portfolio_id = pp.portfolio_name_id
        pg.save
      end
    end
    drop_table      :portfolios
    drop_table      :portfolio_products
    rename_table    :portfolio_names, :portfolios    
  end
  
  
  
  def down
    rename_table    :portfolios, :portfolio_names
    create_table :portfolios do |t|
      t.integer :portfolio_name_id
      t.integer :group_id
      t.timestamps
    end
    create_table :portfolio_products do |t|
      t.integer :portfolio_name_id
      t.integer :portfolio_id
      t.integer :product_id
      t.timestamps
    end
    remove_column      :product_groups, :portfolio_id
  end
end
