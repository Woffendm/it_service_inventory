class AddAppSettings < ActiveRecord::Migration
  def up
    add_column :app_settings, :allocation_precision, :integer, :default => 1
    add_column :app_settings, :fte_hours_per_week, :float, :default => 40
  end

  def down
    remove_column :app_settings, :allocation_precision
    remove_column :app_settings, :fte_hours_per_week
  end
end