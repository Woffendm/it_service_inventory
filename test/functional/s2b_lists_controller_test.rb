require File.dirname(__FILE__) + '/s2b_lists_controller_test'
require File.expand_path('../../test_helper', __FILE__)

class ListsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  include Redmine::I18n

  load_my_fixtures(['custom_fields'])

  def setup
    
    Setting.host_name = 'test.example.com'
    
    @issue = Issue.first
    @issue_id = @issue.id

    @user = User.find_by_login("admin")
    
    @controller = S2bListsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def teardown
    reset_fixtures
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
end
