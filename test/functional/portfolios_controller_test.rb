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
    put :update, :id => @portfolio, :portfolio => { :portfolio_name_id => @portfolio_name.id }
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end


  test "should add product to portfolio if not already in portfolio" do
    put :update, :id => @portfolio, :portfolio => { :portfolio_name_id => @portfolio_name.id },
        :product => {:id => products(:dnc)}
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should add product to group's list of products if not already in it when added to portfolio" do
    @product = Product.create(:name => "new product")
    put :update, :id => @portfolio, :portfolio => {:portfolio_name_id => @portfolio_name.id },
        :product => {:id => @product.id}
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should not add product to portfolio if already in portfolio" do
    put :update, :id => @portfolio, :portfolio => { :portfolio_name_id => @portfolio_name.id },
        :product => {:id => products(:itsi)}
    assert_response :success
  end


  test "should destroy portfolio" do
    group = @portfolio.group
    assert_difference('Portfolio.count', -1) do
      delete :destroy, :id => @portfolio
    end
    assert_redirected_to edit_group_path(group)
  end
end
