require 'test_helper'

class  Api::V1::CategoriesControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "anyone should index categories" do
    sign_in :supervisor, supervisors(:supervisor)
    get :index
    assert_response :ok
    sign_out supervisors(:supervisor)
    
    get :index
    assert_response :ok

    sign_in :user, users(:user)
    get :index
    assert_response :ok
    sign_out users(:user)
    
    sign_in :user, users(:admin)
    get :index
    assert_response :ok
  end

  # ---------------- Show ----------------------- #
  test "anyone should show a category" do
    sign_in :supervisor, supervisors(:supervisor)
    get :show, id: categories(:alcohol).id
    assert_response :ok
    sign_out supervisors(:supervisor)
    
    get :show, id: categories(:alcohol).id
    assert_response :ok

    sign_in :user, users(:user)
    get :show, id: categories(:alcohol).id
    assert_response :ok
    sign_out users(:user)

    sign_in :user, users(:admin)
    get :show, id: categories(:alcohol).id
    assert_response :ok
  end

  # ---------------- Create ----------------------- #

  test "administrator should create a category" do
    sign_in :user, users(:admin)

    assert_difference('Category.count') do
      post :create, name: 'food'
      assert_response :created
    end
  end

  test "clients and supervisors or anyone should not create a category" do

    assert_no_difference('Category.count') do
      post :create, name: 'food'
      assert_response :unauthorized

      sign_in :user, users(:user)
      post :create, name: 'food'
      assert_response :unauthorized

      sign_in :supervisor, supervisors(:supervisor)
      post :create, name: 'food'
      assert_response :unauthorized
    end
  end
  # ---------------- Update ----------------------- #

  test "administrator should update a category" do
    sign_in :user, users(:admin)
    put :update, { id: categories(:alcohol).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
  end


  test "clients and supervisors and any user not logged  should not update a category" do
    put :update, { id: categories(:alcohol).id, name: 'updated' }
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, { id: categories(:alcohol).id, name: 'updated' }
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    put :update, { id: categories(:alcohol).id, name: 'updated' }
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized
  end


  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a category" do
    sign_in :user, users(:admin)

    assert_difference('Category.count', -1) do
      delete :destroy, id: categories(:alcohol).id
      assert_response :ok
    end
  end


  test "clients and supervisors or anyone should not destroy a category" do
    assert_no_difference('Category.count') do
      delete :destroy, id: categories(:alcohol).id
      assert_response :unauthorized
    end

    sign_in :user, users(:user)
    assert_no_difference('Category.count') do
      delete :destroy, id: categories(:alcohol).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    assert_no_difference('Category.count') do
      delete :destroy, id: categories(:alcohol).id
      assert_response :unauthorized
    end
  end

end
