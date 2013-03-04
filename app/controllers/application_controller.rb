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
  before_filter :load_current_fiscal_year
  before_filter :set_user_language
  before_filter :require_login
  before_filter :remind_user_to_set_allocations
  rescue_from CanCan::AccessDenied, :with => :permission_denied
  rescue_from OmniAuth::Error, :with => :invalid_credentials
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from ActionController::RoutingError, :with => :page_not_found



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
      unless Employee.where(:osu_username => session[:current_user_osu_username]).blank? 
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


    # Loads the current fiscal year. If the current fiscal year does not exist (meaning it has been 
    # deleted on accident) then the application creates a new one based off of the currently set
    # fiscal year value.
    def load_current_fiscal_year
      @current_fiscal_year = AppSetting.get_current_fiscal_year
      if @current_fiscal_year.nil?
        FiscalYear.create(:year => AppSetting.find_by_code("current_fiscal_year").value)
        @current_fiscal_year = AppSetting.get_current_fiscal_year
      end
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


    # Sorts given active record objects thing by the given paramaters. 
    def sort_results(params, objects)
      return objects if objects.blank?
      @order = params[:order]
      @current_order = params[:current_order]
      @ascending = params[:ascending]
      @table = params[:table]
      @ascending = 'true' if @ascending.blank?
      unless @order.blank?
        objects = objects.eager_load(@table) unless @table.blank?
        if @ascending == 'true' && (@current_order == @order || @current_order.blank?)
          objects = objects.order(@order).reverse_order
          @ascending = 'false'
        else
          objects = objects.order(@order)
          @ascending = 'true'
        end
      else
        if objects.first.respond_to?(:name)
          objects = objects.order(:name)
         else
          objects = objects.order(:name_last)
        end
      end 
      return objects
    end


    # If the current user has no allocations AND they have not disabled this preference, then a 
    # flash message will display on every page load instructing them to set up their allocations.
    def remind_user_to_set_allocations
      if @current_user.new_user_reminder &&
         @current_user.get_total_service_allocation(@current_fiscal_year).zero?
        edit_employee_link = "<a href = \"" + edit_employee_path(@current_user.id) + 
                             "\">" + t(:here) + "</a>"
        user_settings_link = "<a href = \"" + user_settings_employee_path(@current_user.id) + 
                             "\">" + t(:user_settings) + " </a>"
        flash[:message] = (t(:new_user_message_0) + edit_employee_link + 
                          t(:new_user_message_1) + user_settings_link).html_safe
      end
    end


    # Logs an exception's contents, along with what page it was raised on.
    def log_error(exception, raised_on)
      current_user_string = ""
      current_user_string = (", User ID: " + @current_user.id.to_s) if @current_user
      logger.error "\n!!!!!!!!!!!!!!!!!! ERROR  BEGINS !!!!!!!!!!!!!!!!!!!!!!"
      logger.error exception
      logger.error ("Raised on: " + raised_on + current_user_string + "\n")
    end


    # Redirects user to 'invalid credentials' error page
    def invalid_credentials(exception)
      log_error(exception, request.fullpath)
      render "errors/invalid_credentials"
    end


    # Redirects user to 'permission denied' error page
    def permission_denied(exception)
      log_error(exception, request.fullpath)
      render "errors/permission_denied"
    end


    # Redirects user to 'page not found' error page
    def page_not_found(exception)
      log_error(exception, request.fullpath)
      render "errors/page_not_found"
    end


    # Redirects user to 'page not found' error page
    def record_not_found(exception)
      log_error(exception, request.fullpath)
      render "errors/record_not_found"
    end
end