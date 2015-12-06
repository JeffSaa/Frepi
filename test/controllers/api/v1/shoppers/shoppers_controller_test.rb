require 'test_helper'
require 'faker'

class  Api::V1::Shoppers::ShoppersControllerTest < ActionController::TestCase

 # ---------------- Index --------------------- #
  test "clients, supervisors and anyone should not index supervisor" do
    get :index
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :index
    assert_response :unauthorized

  end


  test "only administrator should index supervisors" do
    sign_in :user, users(:admin)
    get :index
    assert_response :ok
    sign_out users(:admin)

    sign_in :supervisor, supervisors(:supervisor)
    get :index
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "only a supervisor should do show action" do
    sign_in :user, users(:admin)
    get :show, id: shoppers(:shopper).id

    assert_response :ok
  end


  test "users should not do show" do
    sign_in :user, users(:user)
    get :show, id: shoppers(:shopper).id

    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "only a admin can create a supervisor" do
    sign_in :user, users(:admin)
    assert_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      status: Shopper::STATUS.sample, shopper_type: Shopper::TYPES.sample }

      assert_response :created
    end

  end


  test 'An user or an supervisor should not create an supervisor' do
    assert_no_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      status: Shopper::STATUS.sample, shopper_type: Shopper::TYPES.sample }

      assert_response :unauthorized
    end


    sign_in :user, users(:user)

    assert_no_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      status: 0}

      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    assert_no_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      status: 0 }

      assert_response :unauthorized
    end

  end

  # ---------------- Update ----------------------- #

  test "Only a admin should update " do
    sign_in :user, users(:admin)
    put :update, id: shoppers(:shopper).id, first_name: 'updated'
    response = JSON.parse(@response.body)

    assert_match('updated', response['firstName'])
    assert_response :ok
  end

  test "Users and supervisors should not update a supervisor" do
    put :update, id: shoppers(:shopper).id, first_name: 'updated'
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update,  id: shoppers(:shopper).id, first_name: 'updated'
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    put :update,  id: shoppers(:shopper).id, first_name: 'updated'
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #
  test "Only a admin should destroy" do
    sign_in :user, users(:admin)

    delete :destroy, id: shoppers(:shopper).id
    response = JSON.parse(@response.body)

    assert_equal(false, response['active'])
    assert_response :ok
  end

  test "should not destroy (supervisor or anyone)" do

    assert_no_difference('Shopper.count') do
      delete :destroy, id: shoppers(:shopper).id
      assert_response :unauthorized

      sign_in :supervisor, supervisors(:supervisor)
      delete :destroy,  id: shoppers(:shopper).id
      assert_response :unauthorized
    end

    sign_in :user, users(:user)
    get :destroy, id: shoppers(:shopper).id
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    get :destroy, id: shoppers(:shopper).id
    assert_response :unauthorized
  end
end
