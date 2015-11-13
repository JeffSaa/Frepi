class SessionsController < ApplicationController

  skip_before_action :authenticate_user!, :require_administrator, :authenticate_supervisor!

  def create
    # TODO: refactor code
    user = User.find_by(provider: params[:provider], uid: params[:uid])

    if user
      sign_in(:user, user)
      render(json: user, status: :accepted, root: 'user')
    elsif params.keys.size > 4
      user = User.from_omniauth(user_params)
      sign_in :user, user
      render(json: user, status: :created, root: 'user')
    else
      head(:not_found)
    end
  end

  def user_params
    params.permit(:provider, :uid, :email, :name, :last_name, :image)
  end
end
