require 'test_helper'

class Api::V1::PasswordsControllerTest < ActionController::TestCase
  test "should valid token" do
   # user = User.send_reset_password_instructions(email: 'user@frepi.com')

    #post :create, reset_password_token: user.reset_password_token, password: '123456789', password_confirmation: '123456789'
   # assert_response :success

    #post :create, reset_password_token: token, password: '123456789', password_confirmation: '123456789'
   # assert_response :success
  end

   test "token must be not valid" do
    post :create, reset_password_token: 'my token false', password: '123456789', password_confirmation: '123456789'
    
    assert_response :not_found
  end
end
