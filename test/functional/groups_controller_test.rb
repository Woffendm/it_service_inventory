require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  setup do
    @group = groups(:cws)
    @employee = employees(:yoloswag)
    session[:current_user_name] = employees(:michael).full_name
    session[:cas_user] = employees(:michael).uid
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


  test "should not create group without name" do
    assert_no_difference('Group.count') do
      post :create, :group => { :name => nil }
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
  
  
  test "should not update group without name" do
    put :update, :id => @group, :group => { :name => nil }
    assert_response :success
  end
  
  
  test "should add employee to group if employee id provided" do
    assert_difference('@group.employees.count', 1) do
      put :update, :id => @group, :employee_group => {:employee_id => @employee.id}
    end
    assert_redirected_to edit_group_path(assigns(:group))
  end
  
  
  test "should not add employee to group if employee is already in group" do
    assert_no_difference('EmployeeGroup.count') do
      put :update, :id => @group, :employee_group => {:employee_id => employees(:michael).id}
    end
    assert_response :success
  end


  test "should get services of group if given group id" do
    get :services, :group => {:id => @group.id}
    assert_equal @group.services(AppSetting.get_current_fiscal_year), assigns(:services)
    assert_response :success
  end
  
  
  test "should get all services if no group id given" do
    get :services, :group => {:id => "0"}
    assert_equal assigns(:services), Service.joins(:employees).uniq.order(:name)
    assert_response :success
  end


  test "should filter groups by name" do
    get :index, :search => {:name => "cws"}
    assert_not_nil assigns(:groups)
    assert_equal @group, assigns(:groups).first
  end


  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, :id => @group
    end
    assert_redirected_to groups_path
  end
end
