require 'test_helper'

class Shoppers::SchedulesControllerTest < ActionController::TestCase

# NOTE: NOT BELONGS TO MVP

=begin
 # ---------------- Index --------------------- #
  test "users or any no logged should not index the schedules of a shopper" do
    get :index, shopper_id: shoppers(:shopper).id
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :index, shopper_id: shoppers(:shopper).id
    assert_response :unauthorized
  end

  test "only a shopper should index his own schedules" do
    sign_in :shopper, shoppers(:shopper)
    get :index, shopper_id: shoppers(:shopper).id

    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "only a shopper should do show action" do
    sign_in :shopper, shoppers(:shopper)
    get :show, shopper_id: shoppers(:shopper).id, id: schedules(:one).id
    assert_response :ok
  end


  test "user or anyone not logged should not do show" do
    get :show, shopper_id: shoppers(:shopper).id, id: schedules(:one).id
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :show, shopper_id: shoppers(:shopper).id, id: schedules(:one).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #
  test "only a shopper can create schedules" do
    sign_in :shopper, shoppers(:shopper)
    assert_difference('Schedule.count') do
      post :create, shopper_id: shoppers(:shopper).id,
                    start_hour: "14:00", end_hour: "22:00", day: 'SUNDAY'

      assert_response :created
    end
  end


  test 'should not create schedules, users or anyone no logged' do
    assert_no_difference('Schedule.count') do
      post :create, shopper_id: shoppers(:shopper).id,
                    start_hour: "14:00", end_hour: "22:00", day: 'SUNDAY'
      assert_response :unauthorized

      sign_in :user, users(:user)
      post :create, shopper_id: shoppers(:shopper).id,
                    start_hour: "14:00", end_hour: "22:00", day: 'SUNDAY'
      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #

  test "Only a shopper should update" do
    sign_in :shopper, shoppers(:shopper)
    put :update, shopper_id: shoppers(:shopper).id, id: schedules(:one).id, day: 'SUNDAY'
    response = JSON.parse(@response.body)

    assert_match('SUNDAY', response['day'])
    assert_response :ok
  end

  test "should not update a user or someone not logged" do
    put :update, shopper_id: shoppers(:shopper).id, id: schedules(:one).id, day: 'SUNDAY'
    response = JSON.parse(@response.body)

    assert_no_match('SUNDAY', response['day'])
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, shopper_id: shoppers(:shopper).id, id: schedules(:one).id, day: 'SUNDAY'
    response = JSON.parse(@response.body)

    assert_no_match('SUNDAY', response['day'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "Only a shopper should destroy" do
    sign_in :shopper, shoppers(:shopper)

    assert_difference('Schedule.count', -1) do
      delete :destroy, shopper_id: shoppers(:shopper).id, id: schedules(:one).id
      assert_response :ok
    end
  end

  test "should not destroy a shopper or someone not logged" do
    assert_no_difference('Schedule.count') do
      delete :destroy, shopper_id: shoppers(:shopper).id, id: schedules(:one).id
      assert_response :unauthorized

      sign_in :user, users(:user)
      delete :destroy, shopper_id: shoppers(:shopper).id, id: schedules(:one).id
      assert_response :unauthorized
    end
  end
=end

end
