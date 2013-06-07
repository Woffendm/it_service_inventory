require 'test_helper'

class ProductTypesControllerTest < ActionController::TestCase
  setup do
    session[:current_user_name] = employees(:michael).full_name
    session[:uid] = employees(:michael).uid
    session[:results_per_page] = 25
    @product_type = product_types(:awesome)
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should create product type" do
    assert_difference('ProductType.count', 1) do
      post :create, :product_type => {:name => "new type"}
    end
    assert_redirected_to product_types_path
  end


  test "should not create product type without name" do
    assert_no_difference('ProductType.count') do
      post :create, :product_type => {:name => nil}
    end
    assert_response :success
  end


  test "should update product type" do
    put :update, :id => @product_type, :product_type => { :name => "new name" }
    assert_redirected_to product_types_path
  end


  test "should not update product type without name" do
    put :update, :id => @product_type, :product_type => { :name => nil }
    assert_response :success
  end


  test "should destroy product type" do
    assert_difference('ProductType.count', -1) do
      delete :destroy, :id => @product_type
    end
    assert_redirected_to product_types_path
  end
end
