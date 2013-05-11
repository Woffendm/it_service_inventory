require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase
  setup do
    @employee = employees(:michael)
    session[:current_user_name] = employees(:michael).full_name
    session[:current_user_osu_username] = employees(:michael).osu_username
    session[:results_per_page] = 25
  end


  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employees)
  end


  test "should create employee if valid employee given" do
    assert_difference('Employee.count', 1) do
      post :ldap_create, "name_last"=>"Person", "name_first"=>"New", 
          "osu_username"=>"newperson", "osu_id"=>"34524243342", "email"=>"newperson@pie.com"
    end
    assert_response :success
  end


  test "should not create employee if invalid employee given" do
    assert_no_difference('Employee.count') do
      post :ldap_create, "name_last"=> nil, "name_first"=> nil, 
          "osu_username"=> nil, "osu_id"=> nil, "email"=>nil
    end
    assert_response :success
  end


  test "should show employee" do
    get :show, :id => @employee
    assert_response :success
  end


  test "should get edit" do
    get :edit, :id => @employee
    assert_response :success
  end


  test "should update employee" do
    put :update, :id => @employee, :employee => { :name => "Differnet Name" }
    assert_redirected_to edit_employee_path(assigns(:employee))
  end
  
  
  test "should not update employee if no name given" do
    put :update, :id => @employee, :employee => { :name => nil }
    assert_response :success
  end


  test "should toggle active" do
    @active = employees(:yoloswag)
    assert_difference('Employee.where(:active => true).count', -1) do
      get :toggle_active, :employee => {:id => @active.id}
    end
    assert_response :success
  end
  
  
  test "should get all groups if no employee id given" do
    get :groups, :employee => {:id => "0"}
    assert_equal assigns(:groups), Group.joins(:employees).uniq.order(:name)
    assert_response :success
  end
  
  
  test "should filter employees by name" do
    get :index, :search => {:name => "michael"}
    assert_not_nil assigns(:employees)
    assert_equal @employee, assigns(:employees).first
  end


  test "should destroy employee" do
    assert_difference('Employee.count', -1) do
      delete :destroy, :id => employees(:yoloswag)
    end
    assert_redirected_to employees_path
  end
  
  
  test "should not destroy employee if current user" do
    assert_no_difference('Employee.count') do
      delete :destroy, :id => @employee
    end
    assert_redirected_to employees_path
  end
end
