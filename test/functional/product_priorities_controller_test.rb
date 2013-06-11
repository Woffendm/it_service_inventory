require 'test_helper'

class ProductPrioritiesControllerTest < ActionController::TestCase
  setup do
    session[:cas_user] = employees(:michael).uid
    session[:already_logged_in] = true
    RubyCAS::Filter.fake(session[:cas_user])
    @product_priority = product_priorities(:omega)
  end


  test "should get index" do
    get :index
    assert_response :success
  end


  test "should create product priority" do
    assert_difference('ProductPriority.count') do
      post :create, :product_priority => {:name => "new priority"}
    end
    assert_redirected_to product_priorities_path
  end


  test "should not create product priority without name" do
    assert_no_difference('ProductPriority.count') do
      post :create, :product_priority => {:name => nil}
    end
    assert_response :success
  end


  test "should update product priorities" do
    put :update, :id => @product_priority, :product_priority => { :name => "new name" }
    assert_redirected_to product_priorities_path
  end


  test "should not update product priority without name" do
    put :update, :id => @product_priority, :product_priority => { :name => nil }
    assert_response :success
  end


  test "should destroy product priority" do
    assert_difference('ProductPriority.count', -1) do
      delete :destroy, :id => @product_priority
    end
    assert_redirected_to product_priorities_path
  end
end
