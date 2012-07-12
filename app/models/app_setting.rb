# This class stores the configured settings for the overall application
#
# Author: Michael Woffendin 
# Copyright:

class AppSetting < ActiveRecord::Base
  attr_accessible :code, :active
end
