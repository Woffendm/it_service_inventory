require File.expand_path('../../test_helper', __FILE__)

class S2bBoardsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  include Redmine::I18n

  load_my_fixtures(['custom_fields'])

  def setup
    
    Setting.host_name = 'test.example.com'
    
    @issue = Issue.first
    @issue_id = @issue.id

    @user = User.find_by_login("admin")
    
    @controller = S2bBoardsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def teardown
    reset_fixtures
  end
  
  test "copy pasta test" do
    # log_user('admin', 'admin')   
    @request.session[:user_id] = 1
    Setting.default_language = 'en'
    
    get :index
    assert_response :success
  end
  
  test "should get index with user" do
    User.current = @user
    get :index
    assert_response :success
    assert_template :index
  end
  
  test "should get index issue one" do
    get :index
    assert_response :success
  end
  
  test "should get update_status" do
    get :update_status, :issue_id => @issue_id
    assert_response :success
  end
  
  test "post to update_status" do
    post :update_status, :issue_id => @issue_id
    assert_response :success
  end
  
  test "should get update_progress" do
    get :update_progress
    assert_response :success
  end
  
  test "post to update_progress" do
    post :update_progress
    assert_response :success
  end
  
  test "should get create" do
    get :create
    assert_response :success
  end
  
  test "should create new issue" do
    
    
    post :create, :subject => "Stuff",
                  :description => "letters!!!",
                  :tracker_id => Tracker.first.id,
                  :project_id => Project.first.id,
                  :assigned_to_id => 3,
                  :priority_id => 1,
                  :fixed_version_id => 1, 
                  :start_date => "2013-10-28",
                  :due_date => "2013-11-5", 
                  :estimated_hours => 5,
                  :author_id => @user.id
                  
    assert_response :success 
  end
  
  
  
end
