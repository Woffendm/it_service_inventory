# This class controls the settings of the entire application such as theme, timezone, etc.
#
# Author: Michael Woffendin 
# Copyright:

class AppSettingsController < ApplicationController
  before_filter :load_permissions
  
  # View with all configurable settings for the application, and forms to alter said settings
  def index
    @themes = Dir.glob("app/assets/stylesheets/themes/**/*")
    (0..@themes.length-1).each do |i|
      @themes[i] = @themes[i].from(23)
    end
  end
  
  
  # Updates the application's settings based off selection made on "index" view. 
  def update
    @setting = AppSetting.find(params[:id])
    if @setting.update_attributes(params[:app_setting])
      flash[:notice] = "Theme changed!"
      redirect_to app_settings_path 
      return
     end
       render :index
   end



  private
    # Only authorized users can view and edit app settings 
    def load_permissions
      authorize! :manage, AppSetting
    end
end