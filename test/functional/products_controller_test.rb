require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @product = products(:itsi)
    session[:cas_user] = employees(:michael).uid
    session[:already_logged_in] = true
    RubyCAS::Filter.fake(session[:cas_user])
  end



  test "should get edit" do
    get :edit, :id => @product
    assert_response :success
  end
  
  
  test "should get index" do
    get :index
    assert_not_nil assigns(:products)
    assert_response :success
  end
  
  
  test "should filter products by name" do
    get :index, :search => {:name => "itsi"}
    assert_not_nil assigns(:products)
    assert_equal @product, assigns(:products).first
    assert_equal assigns(:products).length, 1
    assert_response :success
  end
  
  
  test "should filter products by group" do
    @group = groups(:cws)
    @product.groups << @group
    get :index, :search => {:group => @group.id}
    assert_not_nil assigns(:products)
    assert_equal assigns(:products).length, 1
    assert_equal @product, assigns(:products).first
    assert_response :success
  end
  
  
  test "should filter products by priority" do
    get :index, :search => {:product_priority => @product.product_priority_id}
    assert_not_nil assigns(:products)
    assert_equal assigns(:products).length, 1
    assert_equal @product, assigns(:products).first
    assert_response :success
  end
  
  
  test "should filter products by state" do
    get :index, :search => {:product_state => @product.product_state_id}
    assert_not_nil assigns(:products)
    assert_equal assigns(:products).length, 1
    assert_equal @product, assigns(:products).first
    assert_response :success
  end
  
  
  test "should filter products by type" do
    get :index, :search => {:product_type => @product.product_type_id}
    assert_not_nil assigns(:products)
    assert_equal assigns(:products).length, 1
    assert_equal @product, assigns(:products).first
    assert_response :success
  end


  test "should filter products by dependencies" do
    @product.dependencies << products(:dnc)
    get :index, :search => {:dependency => true}
    assert_not_nil assigns(:products)
    assert_equal 1, assigns(:products).length
    assert_equal @product, assigns(:products).first
    assert_response :success
  end


  test "should return all products if filter is blank" do
    get :index, :search => {}
    assert_not_nil assigns(:products)
    assert_equal 2, assigns(:products).length
    assert_response :success
  end


  test "should show product" do
    get :show, :id => @product
    assert_response :success
  end


  test "should create product if valid product given" do
    assert_difference('Product.count', 1) do
      post :create, :product => {:name => "New Product"}
    end
    assert_redirected_to edit_product_path(assigns(:product))
  end


  test "should create product with group" do
    assert_difference('Product.count', 1) do
      post :create, :product => {:name => "New Product"}, 
           :product_groups => {:group_id => groups(:cws).id}
    end
    assert_redirected_to edit_product_path(assigns(:product))
  end


  test "should not create product if invalid product given" do
    assert_no_difference('Product.count') do
      post :create, :name => nil
    end
    assert_redirected_to products_path
  end


  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, :id => products(:dnc)
    end
    assert_redirected_to products_path
  end


  test "should update product" do
    put :update, :id => @product, :product => {:name => "Different Name" }
    assert_redirected_to edit_product_path(@product)
  end
  
  
  test "should add service to product" do
    put :update, :id => @product, :product_service => {:service_id => services(:fails).id}
    assert_redirected_to edit_product_path(@product)
  end
  
  
  test "should add product to group" do
    put :update, :id => @product, :product_group => {:group_id => groups(:dic).id}
    assert_redirected_to edit_product_path(@product)
  end
  
  
  test "should add allocation to product" do
    put :update, :id => @product, :employee_product => {:employee_id => employees(:michael).id,
        :fiscal_year_id => fiscal_years(:year_2014).id}
    assert_redirected_to edit_product_path(@product)
  end
  
  
  test "should not update product if no name given" do
    put :update, :id => @product, :product => {:name => nil }
    assert_response :success
  end
end
