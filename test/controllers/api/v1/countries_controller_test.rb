require 'test_helper'

class  Api::V1::CountriesControllerTest < ActionController::TestCase

  # ---------------- Index --------------------- #

  test "clients and supervisor should not index countries" do
    sign_in :user, users(:user)
    get :index
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    get :index
    assert_response :unauthorized
  end


  test "administrator should index countries" do
    sign_in :user, users(:admin)

    get :index
    assert_response :ok
  end

  # ---------------- Show ----------------------- #

  test "administrator should show a country" do
    sign_in :user, users(:admin)
    get :show, id: countries(:italy).id

    assert_response :ok
  end

  test "clients and supervisor should not show a country" do
    sign_in :user, users(:user)
    get :show, id: countries(:italy).id
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    get :show, id: countries(:italy).id
    assert_response :unauthorized
  end

  # ---------------- Create ----------------------- #

  test "administrator should create a country" do
    sign_in :user, users(:admin)

    assert_difference('Country.count') do
      post :create, name: 'United State Of America'
      assert_response :created
    end
  end


  test "clients and supervisor should not create a country" do
    sign_in :user, users(:user)

    assert_no_difference('Country.count') do
      post :create, name: 'United State Of America'
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    assert_no_difference('Country.count') do
      post :create, name: 'United State Of America'
      assert_response :unauthorized
    end
  end

  # ---------------- Update ----------------------- #

  test "administrator should update a country" do
    sign_in :user, users(:admin)
    put :update, { id: countries(:italy).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_match('updated', response['name'])
    assert_response :ok
  end


  test "clients and supervisor should not update a country" do
    sign_in :user, users(:user)
    put :update, { id: countries(:italy).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized

    sign_out users(:user)

    sign_in :supervisor, supervisors(:supervisor)
    put :update, { id: countries(:italy).id, name: 'updated' }
    response = JSON.parse(@response.body)

    assert_no_match('updated', response['name'])
    assert_response :unauthorized
  end

  # ---------------- Destroy ----------------------- #

  test "administrator should destroy a country" do
    sign_in :user, users(:admin)

    assert_difference('Country.count', -1) do
      delete :destroy, id: countries(:italy).id
      assert_response :ok
    end
  end


  test "clients and supervisor should not destroy a country" do
    sign_in :user, users(:user)
    assert_no_difference('Country.count') do
      delete :destroy, id: countries(:italy).id
      assert_response :unauthorized
    end

    sign_out users(:user)
    sign_in :supervisor, supervisors(:supervisor)

    assert_no_difference('Country.count') do
      delete :destroy, id: countries(:italy).id
      assert_response :unauthorized
    end
  end

end
