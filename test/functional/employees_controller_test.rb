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
    assert_not_nil assigns(:employees)
    assert_response :success
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


  test "should get search_ldap_view" do
    get :search_ldap_view
    assert_response :success
  end


  test "should get ldap search results" do
    get :ldap_search_results, :first_name => "J", :last_name => "Smith"
    assert_not_nil assigns(:data)
    assert_response :success
  end


  test "should update employee notes" do
    put :update, :id => @employee, :employee => {:notes => "Different notes" }
    assert_redirected_to edit_employee_path(@employee)
  end
  
  
  test "should add employee to group" do
    put :update, :id => @employee, :employee_group => {:group_id => groups(:dic)}
    assert_redirected_to edit_employee_path(@employee)
  end
  
  
  test "should add new allocation to employee" do
    put :update, :id => @employee, :employee_allocations => {:service_id => services(:fails).id, :allocation => 0.1, :fiscal_year_id => fiscal_years(:year_2014).id}
    assert_redirected_to edit_employee_path(@employee)
  end
  
  
  test "should reject update if employee is over-allocated" do
    put :update, :id => @employee, :employee => {"employee_allocations_attributes"=> {
        "0"=>{"service_id"=>"9", "id"=>"128", "allocation"=>"0.9"}, 
        "1"=>{"service_id"=>"38", "id"=>"155", "allocation"=>"0.2"}}}
    assert_response :success
  end
  
  
  test "should update all employees via ldap" do
    post :update_all_employees_via_ldap
    assert_redirected_to employees_path
  end
  
  
  test "should update employee settings" do
    post :update_settings, :id => @employee, :employee => {:new_user_reminder => "false"}
    assert_redirected_to user_settings_employee_path(@employee)
  end


  test "should toggle to active" do
    @inactive = employees(:inactive)
    assert_difference('Employee.where(:active => true).count', 1) do
      post :toggle_active, :id => @inactive.id
    end
    assert_redirected_to employees_path
  end
  
  
  test "should toggle to inactive" do
    @active = employees(:yoloswag)
    assert_difference('Employee.where(:active => true).count', -1) do
      post :toggle_active, :id => @active.id
    end
    assert_redirected_to employees_path
  end
  
  
  test "should filter employees by name" do
    get :index, :search => {:name => "michael"}
    assert_not_nil assigns(:employees)
    assert_equal @employee, assigns(:employees).first
    assert_response :success
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
