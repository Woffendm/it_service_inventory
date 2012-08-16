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
  before_filter :set_user_language


  private
    # Loads the currently logged-in user for use by the ability.rb model. First it checks to see if
    # the persion described by the session still exists in the database. If they do, then it stores 
    # the corresponding Employee/User in @current_user. If they don't, then it clears the session. 
    # This should be accomplished by a redirect to the destroy action of the logins controller, but
    # unfortunately Chrome gets upset when there are more than two redirects at once.
    def current_user
      unless Employee.where(:id => session[:current_user_id]).empty? 
        @current_user = Employee.find(session[:current_user_id])
      else
        session[:current_user_id] = nil
        session[:current_user_name] = nil
        session[:results_per_page] = nil
      end
    end


    # Loads the active theme.
    def load_theme
      @current_theme = AppSetting.find_by_code('active-theme').active
    end


    #
    def set_user_language
      if @current_user
        if @current_user.preferred_language
          I18n.locale = @current_user.preferred_language
        else
          I18n.locale = :en
        end
      end
    end
end