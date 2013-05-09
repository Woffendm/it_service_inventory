require 'test_helper'

class PortfoliosControllerTest < ActionController::TestCase
  setup do
    @portfolio = portfolios(:one)
    session[:current_user_name] = employees(:michael).full_name
    session[:current_user_osu_username] = employees(:michael).osu_username
    session[:results_per_page] = 25
    @portfolio_name = portfolio_names(:awesome_stuff)
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should get new" do
    get :new, :group_id => groups(:dic).id
    assert_response :success
  end


  test "should get edit" do
    get :edit, :id => @portfolio, :group_id => groups(:dic).id
    assert_response :success
  end


  test "should create portfolio" do
    @group = groups(:dic)
    assert_difference('Portfolio.count') do
      post :create, :portfolio => { :portfolio_name_id => @portfolio_name.id,
                                    :group_id => @group.id }
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
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
