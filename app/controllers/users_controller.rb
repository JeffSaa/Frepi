class UsersController < ApplicationController
  # NOTE: Only a Super User (administrator) can do any action

  skip_before_action :authenticate_user!, only: :create
  before_action :find_user, except: [:index, :create]

  def index
    render json: User.all
  end

  def show
    render json: @user
  end

  def create
    # TODO: change default user_type, Changes city when the app grow
    user = User.new(user_params.merge(city_id: City.first.id, user_type: 'user'))
    if user.save
      render(json: user, status: :created)
    else
      render(json: user.errors, status: :bad_request)
    end
  end

  def update
    @user.assign_attributes(user_params)
    if @user.save
      render(json: @user, status: :created)
    else
      render(json: @user.errors, status: :bad_request)
    end
  end

  def destroy
    @user.destroy
    render json: @user
  end


  private

  def find_user
    begin
      @user = User.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def user_params
    params.permit(:name, :last_name, :email, :identification, :address,
                  :phone_number, :image, :latitude, :longitude,
                  :password, :password_confirmation)
  end
end
