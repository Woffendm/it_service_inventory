class AddCasAttributesToEmployees < ActiveRecord::Migration
  def up
    rename_column :employees, :osu_username, :uid
    rename_column :employees, :name_first, :first_name
    rename_column :employees, :name_MI, :middle_name
    rename_column :employees, :name_last, :last_name
    add_column    :employees, :ldap_identifier, :string
  end
  
  def down
    rename_column :employees, :uid, :osu_username
    rename_column :employees, :first_name, :name_first
    rename_column :employees, :middle_name, :name_MI
    rename_column :employees, :last_name, :name_last
    remove_column :employees, :ldap_identifier
  end
end
