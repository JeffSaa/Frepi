require 'test_helper'

class Api::V1::Administrator::Statistics::ProductsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, start_date: '2015-12-21', end_date: '2015-12-23', page: 1
    assert_response :success
  end

end
