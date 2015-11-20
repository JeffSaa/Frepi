require 'test_helper'

class Supervisors::Orders::ReceivedControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
