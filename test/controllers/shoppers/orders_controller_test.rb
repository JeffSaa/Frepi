require 'test_helper'

class Shoppers::OrdersControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "anyone should not index the orders of a shopper" do
    get :index, shopper_id: shoppers(:shopper).id
    assert_response :unauthorized

    sign_in :shopper, users(:user)
    get :index, shopper_id: shoppers(:shopper).id
    assert_response :unauthorized
  end

  test "only a shopper should index his owns orders" do
    sign_in :shopper, shoppers(:shopper)
    get :index, shopper_id: shoppers(:shopper).id

    assert_response :ok
  end

  # ---------------- Show ----------------------- #
  test "only a shopper should do show action" do
    sign_in :shopper, shoppers(:shopper)
    get :show, shopper_id: shoppers(:shopper).id, id: orders(:one).id
    assert_response :ok
  end


  test "anyone should not do show action of a shopper" do
    get :show, shopper_id: shoppers(:shopper).id, id: orders(:one).id
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :show, shopper_id: shoppers(:shopper).id, id: orders(:one).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #
  test "only a shopper can accept orders" do
    sign_in :shopper, shoppers(:shopper)

    assert_difference('ShoppersOrder.count') do
      post :create, shopper_id: shoppers(:shopper).id, order_id: orders(:two)
      assert_response :created
    end
  end


  test 'should not create an order, shoppers or anyone no logged' do
    assert_no_difference('ShoppersOrder.count') do
      post :create, shopper_id: shoppers(:shopper).id, order_id: orders(:two)
      assert_response :unauthorized

      sign_in :user, users(:user)
      post :create, shopper_id: shoppers(:shopper).id, order_id: orders(:two)
      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #
  test "Only a shopper should update a order" do
    sign_in :shopper, shoppers(:shopper)
    put :update, shopper_id: shoppers(:shopper).id, id: orders(:one).id, status: 'dispatched'
    response = JSON.parse(@response.body)

    assert_match('dispatched', response['status'])
    assert_response :ok
  end

  test "should not update an order a user or someone not logged" do
    put :update, shopper_id: shoppers(:shopper).id, id: orders(:one).id, status: 'dispatched'
    response = JSON.parse(@response.body)

    assert_no_match('dispatched', response['status'])
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, shopper_id: shoppers(:shopper).id, id: orders(:one).id, status: 'dispatched'
    response = JSON.parse(@response.body)

    assert_no_match('dispatched', response['status'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "Only a shopper should destroy an order" do
    sign_in :shopper, shoppers(:shopper)

    get :destroy, shopper_id: shoppers(:shopper).id, id: orders(:one).id
    response = JSON.parse(@response.body)

    assert_equal(false, response['active'])
    assert_response :ok
  end

  test "should not destroy action a user or someone not logged" do
    delete :destroy, shopper_id: shoppers(:shopper).id, id: orders(:one).id
    assert_not_equal(false, response['active'])
    assert_response :unauthorized

    sign_in :user, users(:user)
    delete :destroy, shopper_id: shoppers(:shopper).id, id: orders(:one).id
    assert_not_equal(false, response['active'])
    assert_response :unauthorized
  end

end
