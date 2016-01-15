require 'test_helper'

class  Api::V1::Supervisors::OrdersControllerTest < ActionController::TestCase

  # ------------------ Core funcionality ------------------ #

  test 'An supervisor accept an order  (RECEIVED to SHOPPING)' do
    total = orders(:two).total_price
    quantity_jhonny = products(:johnny).sales_count
    quantity_jack = products(:jack).sales_count

    sign_in :supervisor, supervisors(:supervisor)
    post :create, shopper_id: shoppers(:shopper).id, order_id: orders(:two)
    response = JSON.parse(@response.body)

    p response
    assert_equal(total, response['totalPrice'].to_f)
    assert_equal(true, response['active'])
    assert_match("SHOPPING", response['status'])

    assert_equal(quantity_jhonny, Product.find(products(:johnny).id).sales_count)
    assert_equal(quantity_jack, Product.find(products(:jack).id).sales_count)
    assert_response :created
  end

end
