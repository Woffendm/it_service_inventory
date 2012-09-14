# This class stores the configured settings for the overall application
#
# Author: Michael Woffendin 
# Copyright:

class AppSetting < ActiveRecord::Base
  attr_accessible :code, :value



  # Sets the number of hours full-time employees work per week
  def self.set_fte_hours_per_week(new_value)
    app_setting = AppSetting.find_by_code("fte_hours_per_week")
    if new_value.to_f > 0
      app_setting.value = new_value
      app_setting.save
      return true
    else
      app_setting.errors.add(:value, "Invalid entry")
      return false
    end
  end
  
  
  # Gets the number of hours full-time employees work per week
  def self.get_fte_hours_per_week
    return AppSetting.find_by_code("fte_hours_per_week").value.to_f.round(1)
  end
  
  
  # Sets level of decimal precision for allocations. 
  def self.set_allocation_precision(new_value)
    app_setting = AppSetting.find_by_code("allocation_precision")
    app_setting.value = new_value
    app_setting.save
  end
  
  
  # Gets level of decimal precision for allocations.
  def self.get_allocation_precision
    return AppSetting.find_by_code("allocation_precision").value.to_f.to_int
  end
end
