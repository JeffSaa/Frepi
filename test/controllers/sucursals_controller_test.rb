require 'test_helper'

class SucursalsControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "clients and shoppers should not index sucursals" do
    sign_in :user, users(:user)
    get :index, store_partner_id: store_partners(:olimpica).id
    assert_response :unauthorized

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    get :index, store_partner_id: store_partners(:olimpica).id
    assert_response :unauthorized
  end


  test "administrator should index sucursals" do
    sign_in :user, users(:admin)

    get :index, store_partner_id: store_partners(:olimpica).id
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "administrator should show a sucursal" do
    sign_in :user, users(:admin)
    get :show, id: sucursals(:olimpica).id, store_partner_id: store_partners(:olimpica).id

    assert_response :ok
  end

  test "clients and shoppers should not show a sucursal" do
    sign_in :user, users(:user)
    get :show, id: sucursals(:olimpica).id, store_partner_id: store_partners(:olimpica).id
    assert_response :unauthorized

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    get :show, id: sucursals(:olimpica).id, store_partner_id: store_partners(:olimpica).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "administrator should create a sucursal" do
    sign_in :user, users(:admin)

    assert_difference('Sucursal.count') do
      post :create, { name: 'Olimpica 84', manager_full_name: 'Santo Domingo', manager_email: 'alexito96@olimpica.com',
                      manager_phone_number: '312453354', phone_number: '3245454563', address: 'Cll 35 # 45',
                      latitude: 84.994333, longitude: 23.345565 , store_partner_id: store_partners(:olimpica).id }

      assert_response :created
    end
  end


  test "clients and shoppers should not create a sucursal" do
    sign_in :user, users(:user)

    assert_no_difference('Sucursal.count') do
      post :create, { name: 'Olimpica 84', manager_full_name: 'Santo Domingo', manager_email: 'alexito96@olimpica.com',
                      manager_phone_number: '312453354', phone_number: '3245454563', address: 'Cll 35 # 45',
                      latitude: 84.994333, longitude: 23.345565, store_partner_id: store_partners(:olimpica).id }

      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('Sucursal.count') do
      post :create, { name: 'Olimpica 84', manager_full_name: 'Santo Domingo', manager_email: 'alexito96@olimpica.com',
                      manager_phone_number: '312453354', phone_number: '3245454563', address: 'Cll 35 # 45',
                      latitude: 84.994333, longitude: 23.345565, store_partner_id: store_partners(:olimpica).id }

      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #

  test "administrator should update a sucursal" do
    sign_in :user, users(:admin)
    put :update, { id: sucursals(:olimpica).id, name: 'updated', store_partner_id: store_partners(:olimpica).id }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
  end


  test "clients and shoppers should not update a sucursal" do
    sign_in :user, users(:user)
    put :update, { id: sucursals(:olimpica).id, name: 'updated', store_partner_id: store_partners(:olimpica).id }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    put :update, { id: sucursals(:olimpica).id, name: 'updated', store_partner_id: store_partners(:olimpica).id }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a sucursal" do
    sign_in :user, users(:admin)

    assert_difference('Sucursal.count', -1) do
      delete :destroy, id: sucursals(:olimpica).id, store_partner_id: store_partners(:olimpica).id
      assert_response :ok
    end
  end


  test "clients and shoppers should not destroy a sucursal" do
    sign_in :user, users(:user)

    assert_no_difference('Sucursal.count') do
      delete :destroy, id: sucursals(:olimpica).id, store_partner_id: store_partners(:olimpica).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('Sucursal.count') do
      delete :destroy, id: sucursals(:olimpica).id, store_partner_id: store_partners(:olimpica).id
      assert_response :unauthorized
    end
  end

end