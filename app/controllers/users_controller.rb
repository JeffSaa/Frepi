class UsersController < ApplicationController

  # NOTE: Only a Super User (administrator) can do any action
  skip_before_action :authenticate_user!, only: :create
  skip_before_action :require_administrator, except: :index
  skip_before_action :authenticate_supervisor!

  def index
    render json: User.all
  end

  def show
    render json: current_user, root: 'user'
  end

  def create
    # TODO: Change city when the app grow
    user = User.new(user_params.merge(city_id: City.first.id, administrator: false))
    if user.save
      sign_in :user, user
      render(json: user, status: :created)
    else
      render(json: user.errors, status: :bad_request)
    end
  end

  def update
    current_user.assign_attributes(user_params)
    if current_user.save
      render(json: current_user)
    else
      render(json: current_user.errors, status: :bad_request)
    end
  end

  def destroy
    # TODO: disable current user
    #current_user.destroy
    render json: current_user
  end


  private

  def user_params
    params.permit(:name, :last_name, :email, :identification, :address,
                  :phone_number, :image, :latitude, :longitude,
                  :password, :password_confirmation, :provider)
  end
end
