class Api::V1::PasswordsController < ApplicationController
  def index

  end

  def create
    token = params[:reset_password_token]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    if token && password && password_confirmation
      user = User.reset_password_by_token( { reset_password_token: token, password: password, password_confirmation: password_confirmation} )
      p user


      if user.id.nil?
        render(json: { message: 'token not found' }, status: :not_found)
      else
        if user.save
          render(json: { message: 'password changed'}, status: :ok)
        else
          render(json: user.errors, status: :bad_request)
        end
      end

    else
      render(json: { message: 'params token or password or password_confirmation is missing' }, status: :bad_request)
    end
  end
end
