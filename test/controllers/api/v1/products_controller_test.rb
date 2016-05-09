require 'test_helper'

class  Api::V1::ProductsControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "anyone should index products" do
    sign_in :supervisor, supervisors(:supervisor)
    get :index, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok
    sign_out supervisors(:supervisor)
    
    get :index, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok

    sign_in :user, users(:user)
    get :index, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok
    sign_out users(:user)

    sign_in :user, users(:admin)
    get :index, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok
  end

  # ---------------- Show ----------------------- #
  test "anyone should show a product" do
    sign_in :supervisor, supervisors(:supervisor)
    get :show, id: products(:johnny).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok
    sign_out supervisors(:supervisor)

    get :show, id: products(:johnny).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok

    sign_in :user, users(:user)
    get :show, id: products(:johnny).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok
    sign_out users(:user)

    sign_in :user, users(:admin)
    get :show, id: products(:johnny).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    assert_response :ok
  end

  # ---------------- Create ----------------------- #
  test "only administrator should create a product" do
    sign_in :user, users(:admin)

    assert_difference('Product.count') do
      post :create, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id,
                    reference_code: '3XVS34234 ', name: 'cococho', store_price: 9.99, frepi_price: 9.99, image: 'URL image',
                    size: '2 Lb', description: 'this is the best cococho', subcategory_id: subcategories(:whiskies), iva: 3.3,
                    percentage: 2.5, active: true

      assert_response :created
    end
  end

  test "clients and supervisors or anyone should not create a product" do

    assert_no_difference('Product.count') do
      post :create, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id,
                    reference_code: '3XVS34234 ', name: 'cococho', store_price: 9.99, frepi_price: 9.99, image: 'URL image',
                    size: '2 Lb', description: 'this is the best cococho', subcategory_id: subcategories(:whiskies)

      assert_response :unauthorized

      sign_in :user, users(:user)
      post :create, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id,
                    reference_code: '3XVS34234 ', name: 'cococho', store_price: 9.99, frepi_price: 9.99, image: 'URL image',
                    size: '2 Lb', description: 'this is the best cococho', subcategory_id: subcategories(:whiskies)

      assert_response :unauthorized

      sign_in :supervisor, supervisors(:supervisor)
      post :create, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id,
                    reference_code: '3XVS34234 ', name: 'cococho', store_price: 9.99, frepi_price: 9.99, image: 'URL image',
                    size: '2 Lb', description: 'this is the best cococho', subcategory_id: subcategories(:whiskies)

      assert_response :unauthorized
    end
  end
  # ---------------- Update ----------------------- #

  test "only administrator should update a product" do
    sign_in :user, users(:admin)
    put :update,  id: products(:johnny).id, name: 'updated', store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id, 
                  size: 'updated', description: 'updated', iva: 50, percentage: 50, active: false
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_match('updated', response['size'])
    assert_match('updated', response['description'])
    assert_match('50', response['percentage'])
    assert_match('50', response['iva'])
    assert_not(response['active'])
    assert_response :ok
  end


  test "clients and supervisors and any user not logged should not update a product" do
    put :update, id: products(:johnny).id, name: 'updated', store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, id: products(:johnny).id, name: 'updated', store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    put :update, id: products(:johnny).id, name: 'updated', store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    response = JSON.parse(@response.body)
    assert_no_match('updated', response['name'])
    assert_response :unauthorized
  end


  # ---------------- Destroy ----------------------- #

  test "only administrator should destroy a subcategory" do
    sign_in :user, users(:admin)
    delete :destroy, id: products(:jack).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
    response = JSON.parse(@response.body)
    assert_equal(false, response['active'])

    assert_response :ok
  end


  test "clients and supervisors or anyone should not destroy a subcategory" do
    assert_no_difference('Product.count') do
      delete :destroy, id: products(:jack).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
      assert_response :unauthorized
    end

    sign_in :user, users(:user)
    assert_no_difference('Product.count') do
      delete :destroy, id: products(:jack).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
      assert_response :unauthorized
    end
    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    assert_no_difference('Product.count') do
      delete :destroy, id: products(:jack).id, store_partner_id: store_partners(:olimpica).id, sucursal_id: sucursals(:olimpica).id
      assert_response :unauthorized
    end
  end

end
