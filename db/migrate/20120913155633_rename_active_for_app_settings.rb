class RenameActiveForAppSettings < ActiveRecord::Migration
  def up
    rename_column :app_settings, :active, :value
  end

  def down
    rename_column :app_settings, :value, :active
  end
end