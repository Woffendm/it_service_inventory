require 'test_helper'

class PortfolioNamesControllerTest < ActionController::TestCase
  setup do
    session[:cas_user] = employees(:michael).uid
    session[:already_logged_in] = true
    RubyCAS::Filter.fake(session[:cas_user])
    @portfolio_name = portfolio_names(:awesome_stuff)
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should create portfolio name" do
    assert_difference('PortfolioName.count', 1) do
      post :create, :portfolio_name => {:name => "new state"}
    end
    assert_redirected_to portfolio_names_path
  end


  test "should not create portfolio name without name" do
    assert_no_difference('PortfolioName.count') do
      post :create, :portfolio_name => {:name => nil}
    end
    assert_response :success
  end


  test "should update portfolio name" do
    put :update, :id => @portfolio_name, :portfolio_name => { :name => "new name" }
    assert_redirected_to portfolio_names_path
  end


  test "should not update portfolio name without name" do
    put :update, :id => @portfolio_name, :portfolio_name => { :name => nil }
    assert_response :success
  end


  test "should destroy portfolio name" do
    assert_difference('PortfolioName.count', -1) do
      delete :destroy, :id => @portfolio_name
    end
    assert_redirected_to portfolio_names_path
  end
end
