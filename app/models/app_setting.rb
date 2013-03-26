# This class stores the configured settings for the overall application
#
# Author: Michael Woffendin 
# Copyright:

class AppSetting < ActiveRecord::Base
  attr_accessible :code, :value
  validate :validate_all_app_settings


  # Validates the current app setting based on its code.
  def validate_all_app_settings
    if code == "allocation_precision"
      unless (value.to_f > 0) && (value.to_f % 1 == 0)
        errors.add(:value, "Not a positive integer")
      end
    elsif code == "fte_hours_per_week" 
      unless (value.to_f > 0) && (value.to_f. <= 168)
        errors.add(:value, "Must be between 0 and 168")
      end
    end
  end


  # Sets a new value for the specified app setting if it is valid
  def self.save_setting(setting, new_value)
    setting.value = new_value
    setting.save
  end


  # Gets the number of hours full-time employees work per week
  def self.get_fte_hours_per_week
    return AppSetting.find_by_code("fte_hours_per_week").value.to_f.round(1)
  end


  # Gets level of decimal precision for allocations.
  def self.get_allocation_precision
    return AppSetting.find_by_code("allocation_precision").value.to_f.to_int
  end
  
  
  # Returns the fiscal year object that corresponds to the currently set fiscal year
  def self.get_current_fiscal_year
    return nil if FiscalYear.first.blank?
    return FiscalYear.find_by_year(AppSetting.find_by_code("current_fiscal_year").value)
  end
  
  
  # Returns the application's REST API key
  # Let's say that this app is running on www.cheese.com and you want to get products from this app.
  # 
  # class Product < ActiveResource::Base
  #   self.site = 'http://www.cheese.com/'
  #   self.format = :json  
  #   headers['app_key'] = 'testo'
  # end
  #
  # Of course 'testo' would have to match the API key specified in this application's settings. 
  def self.get_rest_api_key
    return AppSetting.find_by_code("rest_api_key").value
  end
end
