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
  before_filter :require_login
  before_filter :remind_user_to_set_allocations



  private
    # Redirects user to login page unless they are logged in
    def require_login
        redirect_to Project1::Application.config.config['ldap_login_path'] unless @current_user
    end
    
    
    # Loads the currently logged-in user for use by the ability.rb model. First it checks to see if
    # the persion described by the session still exists in the database. If they do, then it stores 
    # the corresponding Employee/User in @current_user. If they don't, then it clears the session. 
    # This should be accomplished by a redirect to the destroy action of the logins controller, but
    # unfortunately Chrome gets upset when there are more than two redirects at once.
    def current_user
      unless Employee.where(:osu_username => session[:current_user_osu_username]).empty? 
        @current_user = Employee.find_by_osu_username(session[:current_user_osu_username])
      else
        session[:current_user_name] = nil
        session[:results_per_page] = nil
        session[:current_user_osu_username] = nil
      end
    end


    # Loads the active theme.
    def load_theme
      @current_theme = AppSetting.find_by_code('active-theme').active
    end


    # If there is a current user, and if they have a preferred language, then it will set the
    # language to the current user's preferred language. 
    def set_user_language
      if @current_user
        if @current_user.preferred_language
          I18n.locale = @current_user.preferred_language
        else
          I18n.locale = :en
        end
      end
    end
    
    
    # If the current user has no allocations AND they have not disabled this preference, then a 
    # flash message will display on every page load instructing them to set up their allocations.
    def remind_user_to_set_allocations
      if @current_user.new_user_reminder && @current_user.get_total_allocation.zero?
        edit_employee_link = "<a href = \"" + edit_employee_path(@current_user.id) + "\"> HERE </a>"
        user_settings_link = "<a href = \"" + user_settings_employee_path(@current_user.id) + "\">  User Settings </a>"
        flash[:message] = "Welcome to IT Service Inventory! Please take a moment to set up your information by clicking #{edit_employee_link}. <br/><br/> This notice will disable automatically once you add a service allocation, or can be disabled manually from #{user_settings_link}.".html_safe
      end
    end
end