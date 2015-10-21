class Shoppers::ShoppersController < ApplicationController

  skip_before_action :authenticate_shopper!, only: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, except: [:index, :create]

  def index
    render json: Shopper.all
  end

  def show
    establish_headers(current_shopper)
    render json: current_shopper, root: 'shopper'
  end

  def create
    # TODO: change default user_type, Changes city when the app grow
    shopper = Shopper.new(shopper_params.merge(city_id: City.first.id))
    if shopper.save
      establish_headers(shopper)
      sign_in :shopper, shopper
      render(json: shopper, status: :created)
    else
      render(json: shopper.errors, status: :bad_request)
    end
  end

  def update
    current_shopper.assign_attributes(shopper_params)
    if current_shopper.save
      establish_headers(current_shopper)
      render(json: current_shopper)
    else
      render(json: current_shopper.errors, status: :bad_request)
    end
  end

  def destroy
    # TODO: disable current shopper
    #current_shopper.destroy
    render json: current_shopper
  end


  private

  def shopper_params
    params.permit(:first_name, :last_name, :email, :identification, :address, :status,
                  :phone_number, :image, :latitude, :longitude, :active, :password,
                  :password_confirmation, :company_email)
  end


  def establish_headers(shopper)
    header = shopper.generate_token
    response.headers['access-token'] = header["access-token"]
    response.headers['token-type'] = header["token-type"]
    response.headers['client'] = header["client"]
    response.headers['uid'] = header["uid"]
    response.headers['expiry'] = header["expiry"]
  end
end
