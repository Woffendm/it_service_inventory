require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  setup do
    @user = employees(:yoloswag)
    session[:current_user_name] = employees(:michael).full_name
    session[:current_user_osu_username] = employees(:michael).osu_username
    session[:results_per_page] = 24
  end


  test "should get login" do
    get :new
    assert_redirected_to Project1::Application.config.config['ldap_login_path']
  end
  
  
  test "backdoor login to application should be disabled" do
    get :new_backdoor
    assert_redirected_to logins_new_path
  end
  
  
  test "should change results per page" do
    get :change_results_per_page, :results_per_page => 100
    assert_not_nil session[:results_per_page]
    assert_equal session[:results_per_page], "100"
    assert_redirected_to pages_home_path
  end
  
  
  test "should change selected fiscal year" do
    get :change_year, :year => 2014
    assert_not_nil cookies[:year]
    assert_equal cookies[:year], "2014"
    assert_redirected_to pages_home_path
  end
  
  
  test "should create login session" do
    post :create, :username => "yoloswag"
    assert_equal 25, session[:results_per_page]
    assert_equal session[:current_user_name], @user.full_name
    assert_equal session[:current_user_osu_username], @user.osu_username
    assert_redirected_to pages_home_path
  end
  
  
  test "should not create login session if user is not in application" do 
    post :create, :username => "not in application"
    assert_redirected_to logins_new_path
  end
  
  
  test "backdoor login session creation should be disabled" do
    get :create_backdoor, :username => "woffendm"
    assert_redirected_to logins_new_path
  end
  
  
  test "should destroy login session" do
    post :destroy
    assert_nil session[:current_user_name]
    assert_nil session[:current_user_osu_username]
    assert_nil session[:results_per_page]
    assert_redirected_to logins_new_path
  end
end
