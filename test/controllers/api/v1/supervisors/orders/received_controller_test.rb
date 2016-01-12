require 'test_helper'

class  Api::V1::Supervisors::Orders::ReceivedControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in :supervisor, supervisors(:supervisor)

    get :index, page: 1
    assert_response :ok
  end

end
