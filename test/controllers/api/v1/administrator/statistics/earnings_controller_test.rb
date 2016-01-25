require 'test_helper'

class Api::V1::Administrator::Statistics::EarningsControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in :user, users(:admin)
    get :index, start_date: '2015-12-21', end_date: '2015-12-23', page: 1
    assert_response :success
  end

end
