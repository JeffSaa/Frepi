require 'test_helper'

class Supervisors::Orders::DeliveringControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
