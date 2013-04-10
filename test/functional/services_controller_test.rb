require 'test_helper'

class ServicesControllerTest < ActionController::TestCase
  setup do
    @service = services(:one)
    session[:current_user_name] = employees(:one).full_name
    session[:current_user_osu_username] = employees(:one).osu_username
    session[:results_per_page] = 25
  end


  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:services)
  end


  test "should create service" do
    assert_difference('Service.count') do
      post :create, :service => { :name => @service.name }
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
    put :update, :id => @service, :service => { :name => @service.name }
    assert_redirected_to edit_service_path(assigns(:service))
  end


  test "should destroy service" do
    assert_difference('Service.count', -1) do
      delete :destroy, :id => @service
    end
    assert_redirected_to services_path
  end
end
