require 'test_helper'

class Supervisors::Orders::ReceivedControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in :supervisor, supervisors(:supervisor)

    get :index
    assert_response :ok
  end

end
