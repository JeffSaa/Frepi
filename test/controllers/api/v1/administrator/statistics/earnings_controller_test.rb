require 'test_helper'

class Api::V1::Administrator::Statistics::EarningsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
