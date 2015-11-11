require 'test_helper'

class SupervisorsControllerTest < ActionController::TestCase
  setup do
    @supervisor = supervisors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:supervisors)
  end

  test "should create supervisor" do
    assert_difference('Supervisor.count') do
      post :create, supervisor: { active: @supervisor.active, address: @supervisor.address, city_id: @supervisor.city_id, company_email: @supervisor.company_email, first_name: @supervisor.first_name, image: @supervisor.image, last_name: @supervisor.last_name, personal_email: @supervisor.personal_email, phone_numbre: @supervisor.phone_numbre }
    end

    assert_response 201
  end

  test "should show supervisor" do
    get :show, id: @supervisor
    assert_response :success
  end

  test "should update supervisor" do
    put :update, id: @supervisor, supervisor: { active: @supervisor.active, address: @supervisor.address, city_id: @supervisor.city_id, company_email: @supervisor.company_email, first_name: @supervisor.first_name, image: @supervisor.image, last_name: @supervisor.last_name, personal_email: @supervisor.personal_email, phone_numbre: @supervisor.phone_numbre }
    assert_response 204
  end

  test "should destroy supervisor" do
    assert_difference('Supervisor.count', -1) do
      delete :destroy, id: @supervisor
    end

    assert_response 204
  end
end
