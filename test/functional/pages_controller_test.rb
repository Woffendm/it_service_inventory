require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @group = groups(:cws)
    @service = services(:rails)
    session[:current_user_name] = employees(:michael).full_name
    session[:cas_user] = employees(:michael).uid
    session[:results_per_page] = 25
  end


  test "should get home" do
    get :home
    assert_not_nil assigns(:groups)
    assert_not_nil assigns(:services)
    assert_not_nil assigns(:data_to_graph)
    assert_response :success
  end
  
  
  test "should get home search" do
    get :home_search
    assert_nil assigns(:group)
    assert_nil assigns(:service)
    assert_nil assigns(:data_to_graph)
    assert_response :success
  end
  
  
  test "should have data when given only a group" do
    get :home_search, :group => {:id => @group.id}
    assert_not_nil assigns(:group)
    assert_nil assigns(:service)
    assert_not_nil assigns(:data_to_graph)
    assert_response :success
  end
  
  
  test "should have data when given only a service" do
    get :home_search, :service => {:id => @service.id}
    assert_nil assigns(:group)
    assert_not_nil assigns(:service)
    assert_not_nil assigns(:data_to_graph)
    assert_response :success
  end
  
  
  test "should have data when given a group and service" do
    get :home_search, :service => {:id => @service.id}, :group => {:id => @group.id}
    assert_not_nil assigns(:group)
    assert_not_nil assigns(:service)
    assert_not_nil assigns(:data_to_graph)
    assert_response :success
  end
end
