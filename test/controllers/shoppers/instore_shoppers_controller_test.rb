require 'test_helper'

class Shoppers::InstoreShoppersControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in :supervisor, supervisors(:supervisor)
    get :index

    assert_response :success
  end

end
