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

    assert_equal(total, response['totalPrice'].to_f)
    assert_equal(true, response['active'])
    assert_match("SHOPPING", response['status'])

    assert_equal(quantity_jhonny, Product.find(products(:johnny).id).sales_count)
    assert_equal(quantity_jack, Product.find(products(:jack).id).sales_count)
    assert_response :created
  end


  test "An supervisor return a order to received status" do
    total = orders(:one).total_price
    quantity_jhonny = products(:johnny).sales_count
    quantity_jack = products(:jack).sales_count
    shoppers = orders(:one).shopper
    sales_jhonny = Product.find(products(:johnny).id).sales_count
    sales_jack = Product.find(products(:jack).id).sales_count

    sign_in :supervisor, supervisors(:supervisor)
    delete :destroy, id: orders(:one)
    response = JSON.parse(@response.body)
    

    assert_equal(total, response['totalPrice'].to_f)
    assert_equal(true, response['active'])
    assert_match("RECEIVED", response['status'])
    assert_equal(sales_jack - quantity_jack, Product.find(products(:jack).id).sales_count)
    assert_equal(sales_jhonny - quantity_jhonny, Product.find(products(:johnny).id).sales_count)
  end

  test "An supervisor can disable a order if the status is RECEIVED" do
    total = orders(:two).total_price
    shoppers = orders(:two).shopper
    

    sign_in :supervisor, supervisors(:supervisor)
    delete :destroy, id: orders(:two)
    response = JSON.parse(@response.body)
    

    assert_equal(false, response['active'])
    assert_match("RECEIVED", response['status'])
  end

end
