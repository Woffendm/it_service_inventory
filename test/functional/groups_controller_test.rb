require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  setup do
    @group = groups(:cws)
    session[:current_user_name] = employees(:michael).full_name
    session[:current_user_osu_username] = employees(:michael).osu_username
    session[:results_per_page] = 25
  end


  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end


  test "should create group" do
    assert_difference('Group.count') do
      post :create, :group => { :name => "New Group" }
    end
    assert_redirected_to groups_path
  end


  test "should show group" do
    get :show, :id => @group
    assert_response :success
  end


  test "should get edit" do
    get :edit, :id => @group
    assert_response :success
  end


  test "should update group" do
    put :update, :id => @group, :group => { :name => "Different Name" }
    assert_redirected_to edit_group_path(assigns(:group))
  end


  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, :id => @group
    end
    assert_redirected_to groups_path
  end
end
