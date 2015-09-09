class SessionsController < ApplicationController

  skip_before_action :authenticate_user!, :require_administrator

  def create
    user = User.find_by(provider: params[:provider], uid: params[:uid])

    if user
      sign_in(:user, user)
      render(json: user, status: :accepted)
    elsif params.keys.size > 4
      user = User.from_omniauth(user_params)
      sign_in :user, user
      render(json: user, status: :created)
    else
      head(:not_found)
    end

  end

  def user_params
    params.permit(:provider, :uid, :email, :name, :last_name, :image)
  end
end
