class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :name
      t.string :email
      t.string :osu_username
      t.string :osu_id
      t.text :notes
      t.timestamps
    end
  end
end
