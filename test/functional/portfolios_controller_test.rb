require 'test_helper'

class PortfoliosControllerTest < ActionController::TestCase
  setup do
    @portfolio = portfolios(:one)
    session[:current_user_name] = employees(:one).full_name
    session[:current_user_osu_username] = employees(:one).osu_username
    session[:results_per_page] = 25
    @portfolio_name = portfolio_names(:two)
  end


  test "should get edit" do
    get :edit, :id => @portfolio
    assert_response :success
  end


  test "should update portfolio" do
    put :update, :id => @portfolio, :portfolio => { :portfolio_name_id => @portfolio_name.id }
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end


  test "should destroy portfolio" do
    group = @portfolio.group
    assert_difference('Portfolio.count', -1) do
      delete :destroy, :id => @portfolio
    end
    assert_redirected_to edit_group_path(group)
  end
end
