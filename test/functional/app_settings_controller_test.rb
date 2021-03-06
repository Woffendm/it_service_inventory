require 'test_helper'

class AppSettingsControllerTest < ActionController::TestCase
  setup do
    session[:cas_user] = employees(:michael).uid
    session[:already_logged_in] = true
    RubyCAS::Filter.fake(session[:cas_user])
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should get admins" do
    get :admins
    assert_response :success
  end


  test "should add site admin" do
    @not_admin = employees(:yoloswag)
    assert_difference('Employee.where(:site_admin => true).count', 1) do
      post :add_admin, :employee => {:id => @not_admin.id}
    end
    assert_redirected_to admins_app_settings_path
  end


  test "should remove site admin" do
    @admin = employees(:admin)
    assert_difference('Employee.where(:site_admin => true).count', -1) do
      post :remove_admin, :employee => @admin
    end
    assert_redirected_to admins_app_settings_path
  end


  test "should update app settings if valid" do
    post :update_settings, :app_setting => {"current_fiscal_year" => "2014",
       "allocation_precision" => 3, "rest_api_key" => "testa", "fte_hours_per_week" => 39.0, "open_login" => "true", "logo_url" => "", "full_screen" => "true", "filter_position" => "Left"}
    assert_redirected_to app_settings_path
  end
  
  
  test "should not update app settings if invalid" do
    post :update_settings, :app_setting => {"current_fiscal_year" => "invalid",
       "allocation_precision" => "invalid", "rest_api_key" => "invalid", "fte_hours_per_week" => "invalid", "open_login" => "invalid", "logo_url" => "invalid", "full_screen" => "invalid", "filter_position" => "invalid"}
    assert_response :success
  end
end
