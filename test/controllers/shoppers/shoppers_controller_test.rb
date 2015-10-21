require 'test_helper'
require 'faker'

class Shoppers::ShoppersControllerTest < ActionController::TestCase

 # ---------------- Index --------------------- #
  test "clients, shoppers and anyone should not index shopper" do
    get :index
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :index
    assert_response :unauthorized

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    get :index
    assert_response :unauthorized
  end


  test "only administrator should index shoppers" do
    sign_in :user, users(:admin)
    get :index

    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "only a shopper should do show action" do
    sign_in :shopper, shoppers(:shopper)
    get :show, id: shoppers(:shopper).id

    assert_response :ok
  end


  test "users should not do show" do
    sign_in :user, users(:user)
    get :show, id: users(:user).id

    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "only a admin can create a shopper" do
    sign_in :user, users(:admin)
    assert_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123', status: 'active' }

      assert_response :created
    end

  end


  test 'An user or an shopper should not create an shopper' do
    assert_no_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123', status: 'active' }

      assert_response :unauthorized
    end


    sign_in :user, users(:user)

    assert_no_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123', status: 0}

      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('Shopper.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123', status: 0 }

      assert_response :unauthorized
    end

  end

  # ---------------- Update ----------------------- #

  test "Only a shopper should update " do
    sign_in :shopper, shoppers(:shopper)
    put :update, { id: users(:admin).id, first_name: 'updated' }
    response = JSON.parse(@response.body)

    assert_match('updated', response['firstName'])
    assert_response :ok
  end

  test "Users should not update a shopper" do
    put :update, { id: users(:user).id, first_name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['firstName'])
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, { id: users(:user).id, first_name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['firstName'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #
  # TODO: Create test
=begin
  test "administrator should destroy a user" do
    sign_in :user, users(:admin)

    assert_difference('Country.count', -1) do
      delete :destroy, id: users(:italy).id
      assert_response :ok
    end
  end


  test "clients and shoppers should not destroy a user" do
    sign_in :user, users(:user)
    assert_no_difference('Country.count') do
      delete :destroy, id: users(:italy).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :shopper, shoppers(:shopper)

    assert_no_difference('Country.count') do
      delete :destroy, id: users(:italy).id
      assert_response :unauthorized
    end
  end
=end
end
