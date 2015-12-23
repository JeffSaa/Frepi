require 'test_helper'

class Api::V1::Administrator::Statistics::ProductsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
