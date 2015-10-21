require 'test_helper'

class StatesControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #

  test "clients and shoppers should not index states" do
    sign_in :user, users(:user)
    get :index, country_id: countries(:colombia).id
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    get :index, country_id: countries(:colombia).id
    assert_response :unauthorized
  end


  test "administrator should index states" do
    sign_in :user, users(:admin)

    get :index, country_id: countries(:colombia).id
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "administrator should show a state" do
    sign_in :user, users(:admin)
    get :show, country_id: countries(:colombia).id, id: states(:atlantico)

    assert_response :ok
  end

  test "clients and shoppers should not show a state" do
    sign_in :user, users(:user)
    get :show, { id: states(:atlantico).id, country_id: countries(:colombia).id }
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    get :show, { id: states(:atlantico).id, country_id: countries(:colombia).id }
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "administrator should create a state" do
    sign_in :user, users(:admin)

    assert_difference('State.count') do
      post :create, { name: 'Antioquia', country_id: countries(:colombia).id }
      assert_response :created
    end
  end


  test "clients and shoppers should not create a state" do
    sign_in :user, users(:user)
    assert_no_difference('State.count') do
      post :create, { name: 'Antioquia', country_id: countries(:colombia).id }
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('State.count') do
      post :create, { name: 'Antioquia', country_id: countries(:colombia).id }
      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #

  test "administrator should update a state" do
    sign_in :user, users(:admin)
    put :update, { id: states(:atlantico).id, name: 'updated', country_id: countries(:colombia).id }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
  end


  test "clients and shoppers should not update a state" do
    sign_in :user, users(:user)
    put :update, { id: states(:atlantico).id, name: 'updated', country_id: countries(:colombia).id }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    put :update, { id: states(:atlantico).id, name: 'updated', country_id: countries(:colombia).id }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a state" do
    sign_in :user, users(:admin)

    assert_difference('State.count', -1) do
      delete :destroy, country_id: countries(:colombia).id, id: states(:atlantico).id
      assert_response :ok
    end
  end


  test "clients and shoppers should not destroy a state" do
    sign_in :user, users(:user)

    assert_no_difference('State.count') do
      delete :destroy, country_id: countries(:colombia).id, id: states(:atlantico).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('State.count') do
      delete :destroy, id: states(:atlantico).id, country_id: countries(:colombia).id
      assert_response :unauthorized
    end
  end
end
