require 'test_helper'

class StorePartnersControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #

  test "clients and shoppers should not index store_partners" do
    sign_in :user, users(:user)
    get :index
    assert_response :unauthorized

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    get :index
    assert_response :unauthorized
  end


  test "administrator should index store_partners" do
    sign_in :user, users(:admin)

    get :index
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "administrator should show a store partner" do
    sign_in :user, users(:admin)
    get :show, id: store_partners(:olimpica).id

    assert_response :ok
  end

  test "clients and shoppers should not show a store partner" do
    sign_in :user, users(:user)
    get :show, id: store_partners(:carulla).id
    assert_response :unauthorized

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    get :show, id: store_partners(:carulla).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "administrator should create a store partner" do
    sign_in :user, users(:admin)

    assert_difference('StorePartner.count') do
      post :create, { name: 'Exito', logo: 'http://robohash.org/sitsequiquia.png',
                      description: 'Omnis voluptatem sequi aliquid veniam', nit: '578200561-4' }

      assert_response :created
    end
  end


  test "clients and shoppers should not create a store partner" do
    sign_in :user, users(:user)

    assert_no_difference('StorePartner.count') do
      post :create, { name: 'Exito', logo: 'http://robohash.org/sitsequiquia.png',
                      description: 'Omnis voluptatem sequi aliquid veniam', nit: '4578200561-4' }

      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('StorePartner.count') do
      post :create, { name: 'Exito', logo: 'http://robohash.org/sitsequiquia.png',
                      description: 'Omnis voluptatem sequi aliquid veniam', nit: '4578200561-4' }

      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #

  test "administrator should update a store partner" do
    sign_in :user, users(:admin)
    put :update, { id: store_partners(:olimpica).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
  end


  test "clients and shoppers should not update a store partner" do
    sign_in :user, users(:user)
    put :update, { id: store_partners(:olimpica).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :shopper, shoppers(:shopper)
    put :update, { id: store_partners(:olimpica).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a store partner" do
    sign_in :user, users(:admin)

    assert_difference('StorePartner.count', -1) do
      delete :destroy, id: store_partners(:carulla).id
      assert_response :ok
    end
  end


  test "clients and shoppers should not destroy a store partner" do
    sign_in :user, users(:user)

    assert_no_difference('StorePartner.count') do
      delete :destroy, id: store_partners(:carulla).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('StorePartner.count') do
      delete :destroy, id: store_partners(:carulla).id
      assert_response :unauthorized
    end
  end

end
