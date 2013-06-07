require 'test_helper'

class ProductStatesControllerTest < ActionController::TestCase
  setup do
    session[:current_user_name] = employees(:michael).full_name
    session[:uid] = employees(:michael).uid
    session[:results_per_page] = 25
    @product_state = product_states(:liquid)
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should create product state" do
    assert_difference('ProductState.count', 1) do
      post :create, :product_state => {:name => "new state"}
    end
    assert_redirected_to product_states_path
  end


  test "should not create product state without name" do
    assert_no_difference('ProductState.count') do
      post :create, :product_state => {:name => nil}
    end
    assert_response :success
  end


  test "should update product state" do
    put :update, :id => @product_state, :product_state => { :name => "new name" }
    assert_redirected_to product_states_path
  end


  test "should not update product state without name" do
    put :update, :id => @product_state, :product_state => { :name => nil }
    assert_response :success
  end


  test "should destroy product state" do
    assert_difference('ProductState.count', -1) do
      delete :destroy, :id => @product_state
    end
    assert_redirected_to product_states_path
  end
end
