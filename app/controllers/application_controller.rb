# This class loads stuff used in all other controllers.
#
# Author: Michael Woffendin 
# Copyright:

class ApplicationController < ActionController::Base
  protect_from_forgery
  # Makes the active theme available throughout application (disabled until we get some actual
  # themes, but will be used later)
  # before_filter :load_theme
  before_filter :check_for_api_key
  before_filter  RubyCAS::Filter
  before_filter :get_current_user
  before_filter :load_logo
  before_filter :load_current_fiscal_year
  before_filter :load_allocation_precision
  before_filter :set_user_language
  before_filter :remind_user_to_set_allocations
  rescue_from CanCan::AccessDenied, :with => :permission_denied
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from ActionController::RoutingError, :with => :page_not_found
  helper_method :current_user
  


  # Destroys session and logs user out of CAS.
  def logout
    reset_session
    flash[:notice] = t(:logged_out)
    RubyCAS::Filter.logout(self, root_path)
  end


  private
    # Returns the current user (required method for CanCan)
    def current_user
      return @current_user
    end
    
    
    # Checks to see if the request header contains the api key
    def check_for_api_key
      if ['xml', 'json', 'jsonp'].include?(params[:format]) && request.headers['app_key'] == AppSetting.get_rest_api_key
        session[:cas_user] = Employee.first.uid 
      end
    end
    
    
    # Loads the currently logged-in user. If the user in the session is blank or not in the
    # database, clears the session.
    def get_current_user
      uid = session[:cas_user] 
      @current_user = Employee.find_by_uid(uid) unless uid.blank?
      if @current_user.blank?
        # Destroy old session
        redirect_to :logout
        return
      elsif session[:already_logged_in].blank?
        session[:already_logged_in] = true
        session[:results_per_page] = 25
        flash[:notice] = t(:welcome) + @current_user.first_name + "!"
        redirect_to root_path
      end
    end

    
    # Loads the application's allocation precision as specified in the app settings.
    def load_allocation_precision
      @allocation_precision = AppSetting.get_allocation_precision
    end


    # Loads the current fiscal year. If the current fiscal year does not exist (meaning it has been 
    # deleted on accident) then the application creates a new one based off of the currently set
    # fiscal year value.
    def load_current_fiscal_year
      @current_fiscal_year = AppSetting.get_current_fiscal_year
      if @current_fiscal_year.nil?
        @current_fiscal_year = FiscalYear.order(:updated_at).last
        AppSetting.find_by_code("current_fiscal_year").update_attributes(
            :value => @current_fiscal_year.year)
      end
    end


    # Loads the logo's url specified in the app settings.
    def load_logo
      @logo = Project1::Application.config.config['logo']
    end


    # Loads the active theme.
    def load_theme
      @current_theme = AppSetting.find_by_code('active-theme')
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
      # Because whatever is returned will be paginated, it has to still be an activerecord relation.
      # That is why we return blank objects instead of nil or [] if objects is blank. 
      return objects if objects.blank?
      @order = params[:order]
      @current_order = params[:current_order]
      @ascending = params[:ascending]
      @table = params[:table]
      @ascending = 'true' if @ascending.blank?
      unless @order.blank?
        # Eager load performs a left outer join between the 'objects' and '@table' tables, so that 
        # entries where a relation is not established are included. 
        objects = objects.eager_load(@table) unless @table.blank?
        if @ascending == 'true' && (@current_order == @order || @current_order.blank?)
          objects = objects.order(@order).reverse_order
          @ascending = 'false'
        else
          objects = objects.order(@order)
          @ascending = 'true'
        end
      else
        # If no sorting is given, defaults to sort by name (if the object has a name), or by the 
        # last and first names (for employees)
        if objects.first.respond_to?(:name)
          objects = objects.order(:name)
         else
          objects = objects.order(:last_name, :first_name)
        end
      end 
      return objects
    end


    # If the current user has no allocations AND they have not disabled this preference, then a 
    # flash message will display on every page load instructing them to set up their allocations.
    def remind_user_to_set_allocations
      if !@current_user.blank? && @current_user.new_user_reminder &&
            @current_user.get_total_service_allocation(@current_fiscal_year,
            @allocation_precision).zero?
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