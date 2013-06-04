# This class controls the settings of the entire application such as theme, timezone, etc.
#
# Author: Michael Woffendin 
# Copyright:

class AppSettingsController < ApplicationController
  before_filter :load_permissions
  before_filter :load_settings,     :only => [:index, :update_settings]


  # View-related methods

  # View with a list of all current site admins, and a form to add additional admins
  def admins
    @admins = Employee.where(:site_admin => true).order(:name_last, :name_first)
    @not_admins = Employee.order(:name_last, :name_first) - @admins
  end


  # View with all configurable settings for the application, and forms to alter said settings
  def index
  end


  # Action-related methods

  # Adds site administrator privilages to an employee
  def add_admin
    @new_admin = Employee.find(params[:employee][:id])
    @new_admin.site_admin = true
    @new_admin.save
    flash[:notice] = t(:site_admin) + t(:added)
    redirect_to admins_app_settings_path 
  end


  # Removes site administrator privilages from an employee
  def remove_admin
    @new_admin = Employee.find(params[:employee])
    @new_admin.site_admin = nil
    @new_admin.save
    flash[:notice] = t(:site_admin) + t(:removed)
    redirect_to admins_app_settings_path 
  end


  # Updates the application's settings based off selections made on "index" view. 
  def update_settings
    AppSetting.all.each do |app_setting|
      unless AppSetting.save_setting(app_setting, params[:app_setting][app_setting.code])
        flash[:error] = "One or more of your fields is invalid!"
        render :index
        return
      end
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to app_settings_path 
  end



  private
    # Only authorized users can view and edit app settings 
    def load_permissions
      authorize! :manage, :all
    end
    
    
    # Loads all app settings
    def load_settings
      @fte_hours_per_week = AppSetting.get_fte_hours_per_week
      @allocation_precision = AppSetting.get_allocation_precision
      @current_fiscal_year = AppSetting.get_current_fiscal_year
      @fiscal_years = FiscalYear.active_fiscal_years
      @rest_api_key = AppSetting.get_rest_api_key
    end
end