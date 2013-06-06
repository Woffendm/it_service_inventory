class AddCasAttributesToEmployees < ActiveRecord::Migration
  def up
    add_column    :employees, :uid, :string
    first_name
    last_name
    osu_id
    ldap_identifier
  end
  
  def down
    remove_column :portfolio_products, :portfolio_name_id
  end
end
