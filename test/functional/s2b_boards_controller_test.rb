require File.expand_path('../../test_helper', __FILE__)

class S2bBoardsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  include Redmine::I18n

  load_my_fixtures(['deployments','deployment_tabs','deployment_sections','deployment_approvers','deployment_communication_plans', 'deployment_statuses',
                  'deployment_required_personnels','deployment_steps','deployment_texts','journals'])

  def setup
    
    load_my_fixtures(['deployments','deployment_tabs','deployment_sections','deployment_approvers','deployment_communication_plans', 'deployment_statuses',
                    'deployment_required_personnels','deployment_steps','deployment_texts','journals'])


    Setting.host_name = 'test.example.com'

    @user = User.find_by_login("admin")
  end

  def teardown
    reset_fixtures
  end
  
  #def setup
    
  #  @controller = S2bBoardsController.new
  # @request    = ActionController::TestRequest.new
  #  @response   = ActionController::TestResponse.new
  #  User.current = nil
  #end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_template :index
  end
  
  test "should get index issue one" do
    get :index, :issue_id => 1
    assert_response :success
    assert_template :index
  end
  
  test "should get update_status" do
    get :update_status
    assert_response :success
    assert_template :update_status
  end
  
  test "should get update_progress" do
    get :update_progress
    assert_response :success
    assert_template :update_progress
  end
  
  test "should get update" do
    get :update
    assert_response :success
    assert_template :update
  end
  
  test "should get create" do
    get :create
    assert_response :success
    assert_template :update
  end
  
  test "should get filter_issues_onboard" do
    get :filter_issues_onboard
    assert_response :success
    assert_template :filter_issues_onboard
  end
  
  
  
end