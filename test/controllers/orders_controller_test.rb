require 'test_helper'

class OrdersControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "Shoppers and anyone should not index the orders of a costumer" do
    get :index, user_id: users(:user).id
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    get :index, user_id: users(:user).id
    assert_response :unauthorized
  end

  test "only a client should index his owns orders" do
    sign_in :user, users(:user)
    get :index, user_id: users(:user).id

    assert_response :ok
  end

  # ---------------- Show ----------------------- #
  test "only a user should do show action" do
    sign_in :user, users(:user)
    get :show, user_id: users(:user).id, id: orders(:one).id
    assert_response :ok
  end


  test "supervisors or anyone should not do show of a user" do
    get :show, user_id: users(:user).id, id: orders(:one).id
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    get :show, user_id: users(:user).id, id: orders(:one).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #
  test "only a user can create schedules for the orders" do
    sign_in :user, users(:user)

    assert_difference('Order.count') do
      post :create, {user_id: users(:user).id, products: [ { id: products(:johnny).id, quantity: 10 }, { id: products(:jack).id, quantity: 1 } ]}, { "Accept" => "application/json", "Content-Type" => "application/json" }

      assert_response :created
    end
  end


  test 'should not create an order, supervisors or anyone no logged' do
    assert_no_difference('Order.count') do
      post :create, user_id: users(:user).id, products: [ { id: products(:johnny).id, quantity: 10 }, {id: products(:jack).id, quantity: 1 } ]
      assert_response :unauthorized

      sign_in :supervisor, supervisors(:supervisor)
      post :create, user_id: users(:user).id, products: [ { id: products(:johnny).id, quantity: 10 }, {id: products(:jack).id, quantity: 1 } ]
      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #
  test "Only a user should update" do
    sign_in :user, users(:user)
    put :update, { user_id: users(:user).id, id: orders(:one).id, products: [ { id: products(:johnny).id, quantity: 999 } ]}
    response = JSON.parse(@response.body)

    assert_equal(999, response['ordersProducts'].first['quantity'])
    assert_response :ok
  end

  test "should not update an order or someone not logged" do
    put :update, user_id: users(:user).id, id: orders(:one).id, products: [ { id: products(:johnny).id, quantity: 999 } ]

    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    put :update, user_id: users(:user).id, id: orders(:one).id, products: [ { id: products(:johnny).id, quantity: 999 } ]

    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "Only a user should destroy" do
    sign_in :user, users(:user)

    delete :destroy, user_id: users(:user).id, id: orders(:one).id
    response = JSON.parse(@response.body)

    assert_equal(false, response['active'])
    assert_response :ok
  end

  test "should not destroy a supervisor or someone not logged" do
    assert_no_difference('Order.count') do
      delete :destroy, user_id: users(:user).id, id: orders(:one).id
      assert_response :unauthorized

      sign_in :supervisor, supervisors(:supervisor)
      delete :destroy, user_id: users(:user).id, id: orders(:one).id
      assert_response :unauthorized
    end
  end
end
