# This class loads stuff used in all other controllers.
#
# Author: Michael Woffendin 
# Copyright:

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # Makes the active theme available throughout application.
  before_filter :load_theme
  

  
  private
    # Loads the active theme.
    def load_theme
      @current_theme = AppSetting.find_by_code('active-theme').active
    end
    
    
    def current_user
      @_current_user ||= session[:current_user_id] && Employee.find_by_id(session[current_user_id])
    end
end
