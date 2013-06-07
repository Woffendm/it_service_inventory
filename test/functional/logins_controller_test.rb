require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  setup do
    @user = employees(:yoloswag)
    session[:cas_user] = employees(:michael).uid
    session[:already_logged_in] = true
    RubyCAS::Filter.fake(session[:cas_user])
    session[:results_per_page] = 24
  end
  
  
  test "backdoor login to application should be disabled" do
    get :new_backdoor
    assert_redirected_to logout_path
  end
  
  
  test "should change results per page" do
    get :change_results_per_page, :results_per_page => 100
    assert_not_nil session[:results_per_page]
    assert_equal session[:results_per_page], "100"
    assert_redirected_to pages_home_path
  end
  
  
  test "should change results per page and redirect to referring page" do
    @request.env['HTTP_REFERER'] = employees_path
    get :change_results_per_page, :results_per_page => 100
    assert_not_nil session[:results_per_page]
    assert_equal session[:results_per_page], "100"
    assert_redirected_to employees_path
  end
  
  
  test "should change results per page and redirect to referring page with pagination" do
    @request.env['HTTP_REFERER'] = employees_path + "?page=2"
    get :change_results_per_page, :results_per_page => 100
    assert_not_nil session[:results_per_page]
    assert_equal session[:results_per_page], "100"
    assert_redirected_to employees_path + "?page=1"
  end
  
  
  test "should change results per page and redirect to referring page with additional url items" do
    @request.env['HTTP_REFERER'] = employees_path + "?page=3&ascending=true&commit=Search+&current_order=&order=last_name&search[active]=&search[group]=&search[name]=&search[service]=&table="
    get :change_results_per_page, :results_per_page => 100
    assert_not_nil session[:results_per_page]
    assert_equal session[:results_per_page], "100"
    assert_redirected_to employees_path + "?page=1"
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
    assert_redirected_to pages_home_path
  end
  
  
  test "should not create login session if user is not in application" do 
    post :create, :username => "not in application"
    assert_redirected_to logout_path
  end
  
  
  test "backdoor login session creation should be disabled" do
    get :create_backdoor, :username => "woffendm"
    assert_redirected_to logout_path
  end
  
  
  test "should destroy login session" do
    post :destroy
    assert_redirected_to logout_path
  end
end
