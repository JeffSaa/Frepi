require 'test_helper'

class Api::V1::Explorer::ProductsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, category_id: categories(:alcohol).id
    assert_response :success
  end

end
