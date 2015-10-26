require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
 # ---------------- Index --------------------- #
  test "Shoppers and anyone should not index the schedules of a order" do
    get :index, user_id: users(:user).id, order_id: orders(:one).id
    assert_response :unauthorized

    sign_in :shopper, shoppers(:shopper)
    get :index, user_id: users(:user).id, order_id: orders(:one).id
    assert_response :unauthorized
  end

  test "only a client should index the schedules of his owns orders" do
    sign_in :user, users(:user)
    get :index, user_id: users(:user).id, order_id: orders(:one).id

    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "only a user should do show action" do
    sign_in :user, users(:user)
    get :show, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id
    assert_response :ok
  end


  test "shoppers or anyone should not do show of a user" do
    get :show, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id
    assert_response :unauthorized

    sign_in :shopper, shoppers(:shopper)
    get :show, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #
  test "only a user can create schedules for the orders" do
    sign_in :user, users(:user)
    assert_difference('Schedule.count') do
      post :create, user_id: users(:user).id, order_id: orders(:one).id,
                    start_hour: "14:00", end_hour: "22:00", day: 'SUNDAY'

      assert_response :created
    end
  end


  test 'should not create schedules for an order, shoppers or anyone no logged' do
    assert_no_difference('Schedule.count') do
      post :create, user_id: users(:user).id, order_id: orders(:one).id,
                    start_hour: "14:00", end_hour: "22:00", day: 'SUNDAY'
      assert_response :unauthorized

      sign_in :shopper, shoppers(:shopper)
      post :create, user_id: users(:user).id, order_id: orders(:one).id,
                    start_hour: "14:00", end_hour: "22:00", day: 'SUNDAY'
      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #

  test "Only a user should update" do
    sign_in :user, users(:user)
    put :update, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id, day: 'SUNDAY'
    response = JSON.parse(@response.body)

    assert_match('SUNDAY', response['day'])
    assert_response :ok
  end

  test "should not update a shopper or someone not logged" do
    put :update, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id, day: 'SUNDAY'
    response = JSON.parse(@response.body)

    assert_no_match('SUNDAY', response['day'])
    assert_response :unauthorized

    sign_in :shopper, shoppers(:shopper)
    put :update, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id, day: 'SUNDAY'
    response = JSON.parse(@response.body)

    assert_no_match('SUNDAY', response['day'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "Only a user should destroy" do
    sign_in :user, users(:user)

    assert_difference('Schedule.count', -1) do
      delete :destroy, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id
      assert_response :ok
    end
  end

  test "should not destroy a shopper or someone not logged" do
    assert_no_difference('Country.count') do
      delete :destroy, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id
      assert_response :unauthorized

      sign_in :shopper, shoppers(:shopper)
      delete :destroy, user_id: users(:user).id, order_id: orders(:one).id, id: schedules(:one).id
      assert_response :unauthorized
    end
  end
end
