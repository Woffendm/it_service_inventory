# == Schema Information
#
# Table name: app_settings
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  value      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
      unless (value.to_f > 0) && (value.to_f <= 168)
        errors.add(:value, "Must be between 0 and 168")
      end
    elsif code == "logo" 
      unless value.blank? || value.index("http")
        errors.add(:value, "Must be a valid external URL")
      end
    elsif code == "filter_position" 
      unless value == "Left" || value == "Top"
        errors.add(:value, "Must be Left or Top")
      end
    end
  end


  # Sets a new value for the specified app setting if it is valid
  def self.save_setting(setting, new_value)
    setting.value = new_value
    setting.save
  end


  # Gets the number of hours full-time employees work per week
  def self.fte_hours_per_week
    return AppSetting.find_by_code("fte_hours_per_week").value.to_f.round(1)
  end


  # Gets level of decimal precision for allocations.
  def self.allocation_precision
    return AppSetting.find_by_code("allocation_precision").value.to_f.to_int
  end
  
  
  # Returns the fiscal year object that corresponds to the currently set fiscal year
  def self.current_fiscal_year
    return nil if FiscalYear.first.blank?
    return FiscalYear.find_by_year(AppSetting.find_by_code("current_fiscal_year").value)
  end
  
  
  # Returns the URL of the application's logo. The URL can be either to an external image, 
  # or one within the project. For images within the project, some guessing may be required.
  def self.logo
    return AppSetting.find_by_code("logo").value
  end
  
  
  # Returns where the application's filters should be placed relative to their associated tables 
  # when viewed on a computer
  def self.filter_position
    return AppSetting.find_by_code("filter_position").value
  end
  
  
  # Returns whether ITSI should be full screen or centered when viewed on a computer. 
  def self.full_screen
    return AppSetting.find_by_code("full_screen").value
  end
  
  
  # Returns whether the application accepts open logins or not. If enabled, any
  # authenticated user is automatically added to the application.
  def self.open_login
    return AppSetting.find_by_code("open_login").value
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
  def self.rest_api_key
    return AppSetting.find_by_code("rest_api_key").value
  end
  
  
  # Returns the URL for the application's logo.
  def self.theme
    return AppSetting.find_by_code("theme").value
  end
end
