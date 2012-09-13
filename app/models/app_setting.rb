# This class stores the configured settings for the overall application
#
# Author: Michael Woffendin 
# Copyright:

class AppSetting < ActiveRecord::Base
  attr_accessible :allocation_precision, :fte_hours_per_week
  validates :fte_hours_per_week, :numericality => { :greater_than => 0 }


  # Rounds fte_hours_per_day to the nearest tenth. 
  def rounded_fte_hours_per_week
    return fte_hours_per_week.round(1)
  end
end
