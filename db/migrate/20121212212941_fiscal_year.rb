class FiscalYear < ActiveRecord::Migration
  def change
    create_table :fiscal_years do |t|
      t.integer :year
      t.boolean :active
      t.timestamps
    end
  end
end
