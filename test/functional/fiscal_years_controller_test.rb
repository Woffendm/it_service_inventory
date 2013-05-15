require 'test_helper'

class FiscalYearsControllerTest < ActionController::TestCase
  setup do
    session[:current_user_name] = employees(:michael).full_name
    session[:current_user_osu_username] = employees(:michael).osu_username
    session[:results_per_page] = 25
    @fiscal_year = fiscal_years(:year_2014)
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should create fiscal year" do
    assert_difference('FiscalYear.count', 1) do
      post :create, :fiscal_year => {:year => 2015}
    end
    assert_redirected_to fiscal_years_path
  end


  test "should not create fiscal year without year" do
    assert_no_difference('FiscalYear.count') do
      post :create, :fiscal_year => {:year => nil}
    end
    assert_response :success
  end
  
  
  test "should not create duplicate fiscal year" do
    assert_no_difference('FiscalYear.count') do
      post :create, :fiscal_year => {:year => 2014}
    end
    assert_response :success
  end


  test "should update fiscal year" do
    put :update, :id => @fiscal_year, :fiscal_year => {:year => 2016 }
    assert_redirected_to fiscal_years_path
  end


  test "should not update fiscal year without year" do
    put :update, :id => @fiscal_year, :fiscal_year => {:year => nil }
    assert_response :success
  end
  
  
  test "should not update fiscal year to duplicate year" do
    put :update, :id => @fiscal_year, :fiscal_year => {:year => 2013 }
    assert_response :success
  end
end
