require 'test_helper'
require 'faker'

class  Api::V1::UsersControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "clients, supervisors and anyone should not index users" do
    get :index
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :index
    assert_response :unauthorized

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    get :index
    assert_response :unauthorized
  end


  test "only administrator should index users" do
    sign_in :user, users(:admin)
    get :index

    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "anyone user (admin or client) logged should show to myself" do
    sign_in :user, users(:admin)
    get :show, id: users(:admin).id
    assert_response :ok

    sign_in :user, users(:user)
    get :show, id: users(:user).id
    assert_response :ok
  end


  test "supervisors should not do show of a user" do
    sign_in :supervisor, supervisors(:supervisor)
    get :show, id: users(:user).id

    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "anyone can create a user (client)" do

    assert_difference('User.count') do
      post :create, { name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :created
    end

    sign_in :supervisor, supervisors(:supervisor)
    assert_difference('User.count') do
      post :create, { name: 'Edgar', last_name: 'Gajo',
                      email: 'Edgar@frepi.com', identification: '34408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :created
    end
    sign_out supervisors(:supervisor)

    sign_in :user, users(:user)
    assert_difference('User.count') do
      post :create, { name: 'Elena', last_name: 'Nito',
                      email: 'elena@frepi.com', identification: '13408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :created
    end
    sign_out users(:user)

    sign_in :user, users(:admin)
    assert_difference('User.count') do
      post :create, { name: 'Lali', last_name: 'Cuadora',
                      email: 'lali@frepi.com', identification: '3408743553',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :created
    end
  end

  # ---------------- Update ----------------------- #

  test "any user should update only his own information " do
    sign_in :user, users(:admin)
    put :update, { id: users(:admin).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok

    sign_in :user, users(:user)
    put :update, { id: users(:user).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
  end

  test "supervisors should not update an user and user not logged should not update" do
    put :update, { id: users(:user).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    put :update, { id: users(:user).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
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


  test "clients and supervisors should not destroy a user" do
    sign_in :user, users(:user)
    assert_no_difference('Country.count') do
      delete :destroy, id: users(:italy).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    assert_no_difference('Country.count') do
      delete :destroy, id: users(:italy).id
      assert_response :unauthorized
    end
  end
=end
end
