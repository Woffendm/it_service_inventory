require 'test_helper'

class PortfolioNamesControllerTest < ActionController::TestCase
  setup do
    session[:current_user_name] = employees(:michael).full_name
    session[:current_user_osu_username] = employees(:michael).osu_username
    session[:results_per_page] = 25
    @portfolio_name = portfolio_names(:awesome_stuff)
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should create product state" do
    assert_difference('PortfolioName.count') do
      post :create, :portfolio_name => {:name => "new state"}
    end
    assert_redirected_to portfolio_names_path
  end


  test "should not create product state without name" do
    assert_no_difference('PortfolioName.count') do
      post :create, :portfolio_name => {:name => nil}
    end
    assert_response :success
  end


  test "should update product state" do
    put :update, :id => @portfolio_name, :portfolio_name => { :name => "new name" }
    assert_redirected_to portfolio_names_path
  end


  test "should not update product state without name" do
    put :update, :id => @portfolio_name, :portfolio_name => { :name => nil }
    assert_response :success
  end


  test "should destroy product state" do
    assert_difference('PortfolioName.count', -1) do
      delete :destroy, :id => @portfolio_name
    end
    assert_redirected_to portfolio_names_path
  end
end
