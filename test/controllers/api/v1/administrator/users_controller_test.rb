require 'test_helper'
require 'faker'

class Api::V1::Administrator::UsersControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #
  test "clients, supervisors and anyone should not index users" do
    get :index
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :index
    assert_response :unauthorized
    sign_out users(:user)

    sign_in :user, users(:disable_client)
    get :index
    assert_response :unauthorized
    sign_out users(:disable_client)

    sign_in :supervisor, supervisors(:supervisor)
    get :index
    assert_response :unauthorized
  end


  test "only administrator should index users" do
    sign_in :user, users(:admin)
    get :index, page: 1
    sign_out users(:admin)

    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "clients, supervisors and anyone should not show users" do
    get :show, id: users(:user).id
    assert_response :unauthorized

    sign_in :user, users(:user)
    get :show, id: users(:user).id
    assert_response :unauthorized
    sign_out users(:user)

    sign_in :user, users(:disable_client)
    get :show, id: users(:user).id
    assert_response :unauthorized
    sign_out users(:disable_client)

    sign_in :supervisor, supervisors(:supervisor)
    get :show, id: users(:user).id
    assert_response :unauthorized
    sign_out supervisors(:supervisor)
  end

  test "only a admin can be a show action" do
    sign_in :user, users(:admin)
    get :show, id: users(:user).id
    sign_out users(:admin)

    assert_response :ok
  end

  # ---------------- Create ----------------------- #

  test "no one different of administrator can not create a user" do

    assert_no_difference('User.count') do
      post :create, { name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :unauthorized

      sign_in :supervisor, supervisors(:supervisor)
      post :create, { name: 'Edgar', last_name: 'Gajo',
                      email: 'Edgar@frepi.com', identification: '34408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :unauthorized
      sign_out supervisors(:supervisor)

      sign_in :user, users(:user)
      post :create, { name: 'Elena', last_name: 'Nito',
                      email: 'elena@frepi.com', identification: '13408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :unauthorized
      sign_out  users(:user)

      sign_in :user, users(:disable_client)
      post :create, { name: 'Elena', last_name: 'Nito',
                      email: 'elena@frepi.com', identification: '13408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :unauthorized
      sign_out  users(:disable_client)

      sign_in :user, users(:disable_admin)
      post :create, { name: 'Elena', last_name: 'Nito',
                      email: 'elena@frepi.com', identification: '13408743554',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :unauthorized
      sign_out users(:disable_admin)
    end
  end


  test "Only a admin can create others administrators" do
    assert_difference('User.count') do
      sign_in :user, users(:admin)
      post :create, { name: 'Lali', last_name: 'Cuadora',
                      email: 'lali@frepi.com', identification: '3408743553',
                      address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                      latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
                      password: 'frepi123', password_confirmation: 'frepi123'}

      assert_response :created
      sign_out users(:admin)
    end
  end

  # ---------------- Update ----------------------- #

  test "Only a admin can update others administrators" do
    sign_in :user, users(:admin)
    put :update, { id: users(:user).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
    sign_out users(:admin)
  end

  test "no one different of administrator can update an user" do
    put :update, { id: users(:user).id, name: 'updated' }
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    put :update, { id: users(:user).id, name: 'updated' }
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, { id: users(:user).id, name: 'updated' }
    assert_response :unauthorized

    sign_in :user, users(:disable_client)
    put :update, { id: users(:user).id, name: 'updated' }
    assert_response :unauthorized

    sign_in :user, users(:disable_admin)
    put :update, { id: users(:user).id, name: 'updated' }
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #
  test "Only a admin can delete (diasble) others administrators or users" do
    sign_in :user, users(:admin)
    delete :destroy, id: users(:user).id
    response = JSON.parse(@response.body)

    assert_not(response['active'])
    assert_response :ok
    sign_out users(:admin)
  end

  test "no one different of administrator can destroy an user" do
    delete :destroy, id: users(:user).id
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    delete :destroy, id: users(:user).id
    assert_response :unauthorized

    sign_in :user, users(:user)
    delete :destroy, id: users(:user).id
    assert_response :unauthorized

    sign_in :user, users(:disable_client)
    delete :destroy, id: users(:user).id
    assert_response :unauthorized

    sign_in :user, users(:disable_admin)
    delete :destroy, id: users(:user).id
    assert_response :unauthorized
  end
end