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
  
  test "should get index with user" do
    #User.current = @user
    get :index
    assert_response :success
    assert_template :index
    
    #get :index, :params_project_ids => nil
    #assert_response :success
  end
  
  test "post to update_status" do
    post :update_status, :issue_id => @issue_id
    assert_response :success
  end
  
  
  test "post to update_progress" do
    post :update_progress, :issue_id => @issue_id, :done_ratio => 2
    assert_response :success
  end
  
  test "should create new issue" do
    post :create, :subject => "Stuff",
                  :description => "letters!!!",
                  :tracker => Tracker.first.id,
                  :project => Project.first.id,
                  :status => 1,
                  :assignee => 1,
                  :priority => 1,
                  :version => 1, 
                  :date_start => "2013-10-28",
                  :date_end => "2013-11-5", 
                  :time => 5
                  
    assert_response :success 
  end
  
end
