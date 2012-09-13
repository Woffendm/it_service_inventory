class AddNewUserReminder < ActiveRecord::Migration
  def up
    add_column :employees, :new_user_reminder, :boolean, :default => true
  end

  def down
    remove_column :employees, :new_user_reminder
  end
end
