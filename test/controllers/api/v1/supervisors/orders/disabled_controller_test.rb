require 'test_helper'

class Api::V1::Supervisors::Orders::DisabledControllerTest < ActionController::TestCase
   test "should get index" do
    sign_in :supervisor, supervisors(:supervisor)

    get :index
    response = JSON.parse(@response.body)
    assert_not(response.first['active'])
    assert_response :ok
  end

  test "not should get index" do
    get :index
    assert_response :unauthorized
  end


end
