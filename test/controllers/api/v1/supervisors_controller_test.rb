require 'test_helper'

class  Api::V1::SupervisorsControllerTest < ActionController::TestCase
  PASSWORD = 'frepi123'

 # ---------------- Index --------------------- #
  test "clients and anyone should not index supervisor" do
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


  test "only administrator should index supervisors" do
    sign_in :user, users(:admin)
    get :index

    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "only a admin should do show action" do
    sign_in :user, users(:admin)
    get :show, id: supervisors(:supervisor).id

    assert_response :ok
  end


  test "users should not do show" do
    sign_in :user, users(:user)
    get :show, id: users(:user).id

    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "only a admin can create a supervisor" do
    sign_in :user, users(:admin)
    assert_difference('Supervisor.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                      password: PASSWORD, password_confirmation: PASSWORD }

      assert_response :created
    end

  end


  test 'An user or an supervisor should not create an supervisor' do
    assert_no_difference('Supervisor.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                      city_id: cities(:barranquilla), password: PASSWORD,
                      password_confirmation: PASSWORD }

      assert_response :unauthorized
    end


    sign_in :user, users(:user)

    assert_no_difference('Supervisor.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                      city_id: cities(:barranquilla), password: PASSWORD,
                      password_confirmation: PASSWORD }

      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    assert_no_difference('Supervisor.count') do
      post :create, { first_name: 'Benito', last_name: 'Camelo',
                      email: 'benito97@frepi.com', identification: '11408743554',
                      phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                      city_id: cities(:barranquilla), password: PASSWORD,
                      password_confirmation: PASSWORD }

      assert_response :unauthorized
    end

  end

  # ---------------- Update ----------------------- #

  test "Only a supervisor should update " do
    sign_in :user, users(:admin)
    put :update, id: supervisors(:supervisor).id, first_name: 'updated'
    response = JSON.parse(@response.body)

    assert_match('updated', response['firstName'])
    assert_response :ok
  end

  test "Users should not update a supervisor" do
    put :update, id: supervisors(:supervisor).id, first_name: 'updated'
    response = JSON.parse(@response.body)
    assert_response :unauthorized

    sign_in :user, users(:user)
    put :update, id: supervisors(:supervisor).id, first_name: 'updated'
    response = JSON.parse(@response.body)
    assert_response :unauthorized

    sign_in :supervisor, supervisors(:supervisor)
    put :update, id: supervisors(:supervisor).id, first_name: 'updated'
    response = JSON.parse(@response.body)
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
