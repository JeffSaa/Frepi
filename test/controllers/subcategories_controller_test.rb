require 'test_helper'

class SubcategoriesControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "anyone should index subcategories" do
    get :index, category_id: categories(:alcohol).id
    assert_response :ok

    sign_in :user, users(:user)
    get :index, category_id: categories(:alcohol).id
    assert_response :ok
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    get :index, category_id: categories(:alcohol).id
    assert_response :ok
    sign_out supervisors(:supervisor)

    sign_in :user, users(:admin)
    get :index, category_id: categories(:alcohol).id
    assert_response :ok
  end

  # ---------------- Show ----------------------- #
  test "anyone should show a subcategory" do
    get :show, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
    assert_response :ok

    sign_in :user, users(:user)
    get :show, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
    assert_response :ok
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    get :show, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
    assert_response :ok
    sign_out supervisors(:supervisor)

    sign_in :user, users(:admin)
    get :show, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
    assert_response :ok
  end

  # ---------------- Create ----------------------- #
  test "administrator should create a subcategory" do
    sign_in :user, users(:admin)

    assert_difference('Subcategory.count') do
      post :create, name: 'beers', category_id: categories(:alcohol).id
      assert_response :created
    end
  end

  test "clients and supervisors or anyone should not create a subcategory" do

    assert_no_difference('Subcategory.count') do
      post :create, name: 'beers', category_id: categories(:alcohol).id
      assert_response :unauthorized

      sign_in :user, users(:user)
      post :create, name: 'beers', category_id: categories(:alcohol).id
      assert_response :unauthorized

      sign_in :supervisor, supervisors(:supervisor)
      post :create, name: 'beers', category_id: categories(:alcohol).id
      assert_response :unauthorized
    end
  end
  # ---------------- Update ----------------------- #

  test "administrator should update a subcategory" do
    sign_in :user, users(:admin)
    put :update, id: subcategories(:whiskies).id, name: 'updated', category_id: categories(:alcohol).id
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
  end


  test "clients and supervisors and any user not logged should not update a subcategory" do
    put :update, id: subcategories(:whiskies).id, name: 'updated', category_id: categories(:alcohol).id
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, id: subcategories(:whiskies).id, name: 'updated', category_id: categories(:alcohol).id
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    put :update, id: subcategories(:whiskies).id, name: 'updated', category_id: categories(:alcohol).id
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized
  end


  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a subcategory" do
    sign_in :user, users(:admin)

    assert_difference('Subcategory.count', -1) do
      delete :destroy, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
      assert_response :ok
    end
  end


  test "clients and supervisors or anyone should not destroy a subcategory" do
    assert_no_difference('Subcategory.count') do
      delete :destroy, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
      assert_response :unauthorized
    end

    sign_in :user, users(:user)
    assert_no_difference('Subcategory.count') do
      delete :destroy, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
      assert_response :unauthorized
    end
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    assert_no_difference('Subcategory.count') do
      delete :destroy, id: subcategories(:whiskies).id, category_id: categories(:alcohol).id
      assert_response :unauthorized
    end
  end

end