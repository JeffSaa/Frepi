class UsersController < ApplicationController

  #skip_before_action :authenticate_user!, except: :index
  before_action :find_user, except: [:index, :create]

  def index
    render json: User.all
  end

  def show
    render json: @user
  end

  def create
    user = User.new(user_params.merge(city_id: City.first.id))
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
                  :phone_number, :user_type, :image, :latitude, :longitude,
                  :password, :password_confirmation)
  end
end
