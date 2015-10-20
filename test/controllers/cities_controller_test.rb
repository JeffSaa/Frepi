require 'test_helper'

class CitiesControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #

  test "clients and shoppers should not index cities" do
    sign_in :user, users(:user)
    get :index, country_id: countries(:colombia).id, state_id: states(:atlantico).id
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    get :index, country_id: countries(:colombia).id, state_id: states(:atlantico).id
    assert_response :unauthorized
  end


  test "administrator should index cities" do
    sign_in :user, users(:admin)

    get :index, country_id: countries(:colombia).id, state_id: states(:atlantico).id
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "administrator should show a city" do
    sign_in :user, users(:admin)
    get :show, id: cities(:barranquilla).id, country_id: countries(:colombia).id, state_id: states(:atlantico).id

    assert_response :ok
  end

  test "clients and shoppers should not show a city" do
    sign_in :user, users(:user)
    get :show, { id: cities(:palermo).id, country_id: countries(:italy).id,  state_id: states(:sicilia).id }
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    get :show, { id: cities(:palermo).id, country_id: countries(:italy).id,  state_id: states(:sicilia).id }
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "administrator should create a city" do
    sign_in :user, users(:admin)
    post :create, { name: 'Ponedera', country_id: countries(:colombia).id, state_id: states(:atlantico).id }

    assert_response :created
  end


  test "clients and shoppers should not create a city" do
    sign_in :user, users(:user)
    post :create, { name: 'Ponedera', country_id: countries(:colombia).id, state_id: states(:atlantico).id }
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    post :create, { name: 'Ponedera', country_id: countries(:colombia).id, state_id: states(:atlantico).id }
    assert_response :unauthorized
  end

  # ---------------- Update ----------------------- #

  test "administrator should update a city" do
    sign_in :user, users(:admin)
    put :update, { id: cities(:barranquilla).id, name: 'barranquilla 1', country_id: countries(:colombia).id, state_id: states(:atlantico).id }

    assert_response :ok
  end


  test "clients and shoppers should not update a city" do
    sign_in :user, users(:user)
    put :update, { id: cities(:barranquilla).id, name: 'barranquilla 1', country_id: countries(:colombia).id, state_id: states(:atlantico).id }
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    put :update, { id: cities(:barranquilla).id, name: 'barranquilla 1', country_id: countries(:colombia).id, state_id: states(:atlantico).id }
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a city" do
    sign_in :user, users(:admin)
    delete :destroy, id: cities(:barranquilla).id, country_id: countries(:colombia).id, state_id: states(:atlantico).id

    assert_response :ok
  end


  test "clients and shoppers should not destroy a city" do
    sign_in :user, users(:user)
    delete :destroy, id: cities(:barranquilla).id, country_id: countries(:colombia).id, state_id: states(:atlantico).id
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    delete :destroy, id: cities(:barranquilla).id, country_id: countries(:colombia).id, state_id: states(:atlantico).id
    assert_response :unauthorized
  end

end
