require 'test_helper'

class ServicesControllerTest < ActionController::TestCase
  setup do
    @service = services(:rails)
    session[:cas_user] = employees(:michael).uid
    session[:already_logged_in] = true
    RubyCAS::Filter.fake(session[:cas_user])
  end


  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:services)
  end


  test "should create service" do
    assert_difference('Service.count') do
      post :create, :service => { :name => "New Service" }
    end
    assert_redirected_to services_path
  end


  test "should not create service if no name given" do
    assert_no_difference('Service.count') do
      post :create, :service => { :name => nil }
    end
    assert_redirected_to services_path
  end


  test "should show service" do
    get :show, :id => @service
    assert_response :success
  end


  test "should get edit" do
    get :edit, :id => @service
    assert_response :success
  end


  test "should update service" do
    put :update, :id => @service, :service => { :name => "Differnet Name" }
    assert_redirected_to edit_service_path(assigns(:service))
  end
  
  
  test "should not update service if no name given" do
    put :update, :id => @service, :service => { :name => nil }
    assert_response :success
  end


  test "should get groups of service if given service id" do
    get :groups, :service => {:id => @service.id}
    assert_equal @service.groups(AppSetting.get_current_fiscal_year), assigns(:groups)
    assert_response :success
  end
  
  
  test "should get all groups if no service id given" do
    get :groups, :service => {:id => "0"}
    assert_equal assigns(:groups), Group.joins(:employees).uniq.order(:name)
    assert_response :success
  end
  
  
  test "should filter services by name" do
    get :index, :search => {:name => "rails"}
    assert_not_nil assigns(:services)
    assert_equal @service, assigns(:services).first
  end


  test "should destroy service" do
    assert_difference('Service.count', -1) do
      delete :destroy, :id => @service
    end
    assert_redirected_to services_path
  end
end
