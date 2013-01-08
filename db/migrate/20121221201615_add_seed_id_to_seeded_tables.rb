class AddSeedIdToSeededTables < ActiveRecord::Migration
  def up
    add_column :fiscal_years, :seed_id, :int
    add_column :product_states, :seed_id, :int
    add_column :product_types, :seed_id, :int
    
    # Stops us from hosing the database by checking for existing entries and updating the new
    # seed_id column as necessary
    count = 1
    product_type_names = ["Commercial", "Open Source", "In-House", "SAAS", "PAAS"]
    product_type_names.each do |name|
      existing_entry = ProductType.find_by_name(name)
      unless existing_entry.blank?
        existing_entry.update_attribute(:seed_id, count)
      end
      count += 1
    end
    
    count = 1
    product_state_names = ["Alpha", "Beta", "Release Candidate", "General Availability (GA)", "Discontinued"]
    product_state_names.each do |name|
      existing_entry = ProductState.find_by_name(name)
      unless existing_entry.blank?
        existing_entry.update_attribute(:seed_id, count)
      end
      count += 1
    end
  end
  
  
  
  def down
    remove_column :fiscal_years, :seed_id
    remove_column :product_states, :seed_id
    remove_column :product_types, :seed_id
  end
end
