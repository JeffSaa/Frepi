require 'test_helper'

class  Api::V1::SessionsControllerTest < ActionController::TestCase

  test "for get action is not neccesary logged" do
    post :create, uid: 'no exist', provider: 'facebook'

    assert_response :not_found
  end

end
