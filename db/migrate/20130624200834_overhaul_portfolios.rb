class OverhaulPortfolios < ActiveRecord::Migration
  def up
    create_table :product_group_portfolios do |t|
      t.integer :group_id
      t.integer :product_id
      t.integer :portfolio_id
      t.timestamps
    end
    
    create_table :group_portfolios do |t|
      t.integer :portfolio_id
      t.integer :group_id
      t.timestamps
    end
    
    create_table :product_portfolios do |t|
      t.integer :portfolio_id
      t.integer :product_id
      t.timestamps
    end

    # Retrieves all the information required to create new portfolio relations
    pgp_info = ActiveRecord::Base.connection.execute(
          "SELECT pp.product_id, p.group_id, pp.portfolio_name_id 
          FROM portfolio_products AS pp
          JOIN portfolios AS p
          ON p.id = pp.portfolio_id"
    )
    
    # Creates new portfolio relations
    pgp_info.each do |pgp|
      ProductGroupPortfolio.create(:product_id => pgp[0], :group_id => pgp[1], 
            :portfolio_id => pgp[2])
    end

    drop_table      :portfolios
    drop_table      :portfolio_products
    remove_column   :portfolio_names, :global
    rename_table    :portfolio_names, :portfolios    
  end
  
  
  
  
  def down
    rename_table :portfolios, :portfolio_names
    add_column :portfolio_names, :global, :boolean
    
    create_table :portfolio_products do |t|
      t.integer :portfolio_name_id
      t.integer :portfolio_id
      t.integer :product_id
      t.timestamps
    end
    
    create_table :portfolios do |t|
      t.integer :portfolio_name_id
      t.integer :group_id
      t.timestamps
    end
    
    drop_table :product_portfolios
    drop_table :group_portfolios
    drop_table :product_group_portfolios
  end
end



