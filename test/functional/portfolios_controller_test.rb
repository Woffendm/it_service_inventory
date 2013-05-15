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


  test "should create portfolio when given params of valid portfolio" do
    @group = groups(:dic)
    assert_difference('Portfolio.count') do
      post :create, :portfolio => { :portfolio_name_id => @portfolio_name.id,
                                    :group_id => @group.id }
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should create portfolio when given existing portfolio name" do
    assert_difference('Portfolio.count') do
      post :create, :name => "awesome_stuff", :group_id => groups(:dic).id
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should create portfolio when given new portfolio name" do
    assert_difference('Portfolio.count') do
      post :create, :name => "new portfolio name", :group_id => groups(:dic).id
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end


  test "should not create portfolio when group already has portfolio with that name" do
    assert_no_difference('Portfolio.count') do
      post :create, :name => "awesome_stuff", :group_id => groups(:cws).id
    end
    assert_response :success
  end


  test "should update portfolio if given valid portfolio" do
    put :update, :id => @portfolio, :portfolio => { :portfolio_name_id =>
        portfolio_names(:lame_stuff).id }
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end


  test "should add product to portfolio if not already in portfolio" do
    assert_difference('@portfolio.products.count', 1) do
      put :update, :id => @portfolio, :product => {:id => products(:dnc)}
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should add product to group's list of products if not already in it when added to portfolio" do
    @product = Product.create(:name => "new product")
    assert_difference('@portfolio.group.products.count', 1) do
      put :update, :id => @portfolio, :product => {:id => @product.id}
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should not add product to portfolio if already in portfolio" do
    put :update, :id => @portfolio, :product => {:id => products(:itsi)}
    assert_response :success
  end


  test "should filter portfolios by name" do
    get :index, :search => {:name => "awesome"}
    assert_not_nil assigns(:portfolio_names)
    assert_equal @portfolio_name, assigns(:portfolio_names).first
  end


  test "should destroy portfolio" do
    group = @portfolio.group
    assert_difference('Portfolio.count', -1) do
      delete :destroy, :id => @portfolio
    end
    assert_redirected_to edit_group_path(group)
  end
end
