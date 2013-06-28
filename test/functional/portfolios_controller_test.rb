require 'test_helper'

class PortfoliosControllerTest < ActionController::TestCase
  setup do
    @portfolio = portfolios(:awesome_stuff)
    session[:cas_user] = employees(:michael).uid
    session[:already_logged_in] = true
    RubyCAS::Filter.fake(session[:cas_user])
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should get edit" do
    get :edit, :id => @portfolio
    assert_response :success
  end


  test "should create portfolio if name is unique" do
    assert_difference('Portfolio.count') do
      post :create, :portfolio => {:name => "unique name"}
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end


  test "should not create portfolio if name already taken" do
    assert_no_difference('Portfolio.count') do
      post :create, :name => "awesome_stuff"
    end
    assert_redirected_to portfolios_path
  end


  test "should update portfolio if given valid portfolio" do
    put :update, :id => @portfolio, :portfolio => { :name => "new name" }
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end


  test "should add product to portfolio for given group if not already in portfolio" do
    assert_difference('@portfolio.products.count', 1) do
      put :update, :id => @portfolio, :new_product_groups => {"1" => {:product_id => products(:dnc).id, :group_id => groups(:dic).id}}
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should not add product to portfolio for given group if already in portfolio" do
    assert_no_difference('@portfolio.products.count') do
      put :update, :id => @portfolio, :new_product_groups => {"1" => {:product_id => products(:itsi).id, :group_id => groups(:cws).id}}
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end
  
  
  test "should add portfolio to group's list of portfolios if not already in it when new product_group is created" do
    @product = Product.create(:name => "new product")
    assert_difference('@portfolio.groups.count', 1) do
      put :update, :id => @portfolio, :new_product_groups => {"1" => {:product_id => products(:dnc).id, :group_id => groups(:dic).id}}
    end
    assert_redirected_to edit_portfolio_path(assigns(:portfolio))
  end


  test "should filter portfolios by name" do
    get :index, :search => {:name => "awesome"}
    assert_not_nil assigns(:portfolios)
    assert_equal @portfolio, assigns(:portfolios).first
  end


  test "should destroy portfolio" do
    assert_difference('Portfolio.count', -1) do
      delete :destroy, :id => @portfolio
    end
    assert_redirected_to portfolios_path
  end
end
