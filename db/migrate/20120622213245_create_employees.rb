class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :name_first
      t.string :name_last
      t.string :name_MI
      t.string :email
      t.string :osu_username
      t.string :osu_id
      t.boolean :site_admin
      t.text :notes
      t.timestamps
    end
  end
end
