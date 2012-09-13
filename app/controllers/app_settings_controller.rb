# This class controls the settings of the entire application such as theme, timezone, etc.
#
# Author: Michael Woffendin 
# Copyright:

class AppSettingsController < ApplicationController
  before_filter :load_permissions
  
  
  
  # View-related methods
  
  # View with a list of all current site admins, and a form to add additional admins
  def admins
    @admins = Employee.where(:site_admin => true).order(:name_last, :name_first)
    @not_admins = Employee.order(:name_last, :name_first) - @admins
  end
  
  
  # View with all configurable settings for the application, and forms to alter said settings
  def index
    unless AppSetting.first
      AppSetting.create
    end
    @app_settings = AppSetting.first
  end
  
  
  
  # Action-related methods
  
  # Adds site administrator privilages to an employee
  def add_admin
    @new_admin = Employee.find(params[:employee][:id])
    @new_admin.site_admin = true
    @new_admin.save
    flash[:notice] = t(:site_admin) + t(:added)
    redirect_to app_settings_admins_path 
  end
  
  
  # Removes site administrator privilages from an employee
  def remove_admin
    @new_admin = Employee.find(params[:employee])
    @new_admin.site_admin = nil
    @new_admin.save
    flash[:notice] = t(:site_admin) + t(:removed)
    redirect_to app_settings_admins_path 
  end
  
  
  # Updates the application's settings based off selection made on "index" view. 
  def update
    @app_settings = AppSetting.find(params[:id])
    if @app_settings.update_attributes(params[:app_setting])
      flash[:notice] = t(:settings) + t(:updated)
      redirect_to app_settings_path 
      return
    end
    flash[:error] = "something went wrong"
    render :index
  end



  private
    # Only authorized users can view and edit app settings 
    def load_permissions
      authorize! :manage, :all
    end
end