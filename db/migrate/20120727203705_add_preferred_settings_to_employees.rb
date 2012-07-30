class AddPreferredSettingsToEmployees < ActiveRecord::Migration
  def up
    add_column :employees, :preferred_language, :string
    add_column :employees, :preferred_theme, :string
  end
  def down
    remove_column :employees, :preferred_language
    remove_column :employees, :preferred_theme
  end
end
