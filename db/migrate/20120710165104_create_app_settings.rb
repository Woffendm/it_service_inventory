class CreateAppSettings < ActiveRecord::Migration
  def change
    create_table :app_settings do |t|
      t.string :code
      t.string :active
      t.timestamps
    end
  end
end
