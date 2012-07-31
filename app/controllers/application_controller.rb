# This class loads stuff used in all other controllers.
#
# Author: Michael Woffendin 
# Copyright:

class ApplicationController < ActionController::Base
  protect_from_forgery

  # Makes the active theme available throughout application (disabled until we get some actual
  # themes, but will be used later)
  # before_filter :load_theme
  before_filter :current_user



  private
    # Loads the currently logged-in user for use by the ability.rb model. First it checks to see if
    # someone is logged in. If they are, then it stores the corresponding Employee/User in
    # @current_user
    def current_user
      @current_user ||= session[:current_user_id] && Employee.find(session[:current_user_id])
    end


    # Loads the active theme.
    def load_theme
      @current_theme = AppSetting.find_by_code('active-theme').active
    end
end