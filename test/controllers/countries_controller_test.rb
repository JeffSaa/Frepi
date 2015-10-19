require 'test_helper'

class CountriesControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #

  test "clients and shoppers should not index countries" do
    sign_in :user, users(:user)
    get :index
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    get :index
    assert_response :unauthorized
  end


  test "administrator should index countries" do
    sign_in :user, users(:admin)

    get :index
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "administrator should show a country" do
    sign_in :user, users(:admin)
    get :show, id: countries(:italy).id

    assert_response :ok
  end

  test "clients and shoppers should not show a country" do
    sign_in :user, users(:user)
    get :show, id: countries(:italy).id
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    get :show, id: countries(:italy).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "administrator should create a country" do
    sign_in :user, users(:admin)
    post :create, name: 'United State Of America'

    assert_response :created
  end


  test "clients and shoppers should not create a country" do
    sign_in :user, users(:user)
    post :create, name: 'United State Of America'
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    post :create, name: 'United State Of America'
    assert_response :unauthorized
  end

  # ---------------- Update ----------------------- #

  test "administrator should update a country" do
    sign_in :user, users(:admin)
    post :update, { id: countries(:italy).id, name: 'United State Of America' }

    assert_response :ok
  end


  test "clients and shoppers should not update a country" do
    sign_in :user, users(:user)
    put :update, { id: countries(:italy).id, name: 'United State Of America' }
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    put :update, { id: countries(:italy).id, name: 'United State Of America' }
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a country" do
    sign_in :user, users(:admin)
    delete :destroy, id: countries(:italy).id

    assert_response :ok
  end


  test "clients and shoppers should not destroy a country" do
    sign_in :user, users(:user)
    delete :destroy, id: countries(:italy).id
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    delete :destroy, id: countries(:italy).id
    assert_response :unauthorized
  end

end
