require 'test_helper'

class  Api::V1::StorePartnersControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "anyone should index subcategories" do
    get :index
    assert_response :ok

    sign_in :user, users(:user)
    get :index
    assert_response :ok
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    get :index
    assert_response :ok
    sign_out supervisors(:supervisor)

    sign_in :user, users(:admin)
    get :index, category_id: categories(:alcohol).id
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "anyone should show a store parner" do
    get :show, id: store_partners(:olimpica).id
    assert_response :ok

    sign_in :user, users(:user)
    get :show, id: store_partners(:olimpica).id
    assert_response :ok
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    get :show, id: store_partners(:olimpica).id
    assert_response :ok
    sign_out supervisors(:supervisor)

    sign_in :user, users(:admin)
    get :show, id: store_partners(:olimpica).id
    assert_response :ok
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


  test "clients and supervisors should not create a store partner" do
    sign_in :user, users(:user)

    assert_no_difference('StorePartner.count') do
      post :create, { name: 'Exito', logo: 'http://robohash.org/sitsequiquia.png',
                      description: 'Omnis voluptatem sequi aliquid veniam', nit: '4578200561-4' }

      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

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


  test "clients and supervisors should not update a store partner" do
    sign_in :user, users(:user)
    put :update, { id: store_partners(:olimpica).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
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


  test "clients and supervisors should not destroy a store partner" do
    sign_in :user, users(:user)

    assert_no_difference('StorePartner.count') do
      delete :destroy, id: store_partners(:carulla).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    assert_no_difference('StorePartner.count') do
      delete :destroy, id: store_partners(:carulla).id
      assert_response :unauthorized
    end
  end

end
