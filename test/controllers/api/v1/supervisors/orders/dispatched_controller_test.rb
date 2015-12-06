require 'test_helper'

class  Api::V1::Supervisors::Orders::DispatchedControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in :supervisor, supervisors(:supervisor)

    get :index
    assert_response :ok
  end

end
