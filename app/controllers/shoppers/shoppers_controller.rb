class Shoppers::ShoppersController < ApplicationController

  before_action      :set_supervisor, only: [:show, :update, :destroy]
  skip_before_action :authenticate_supervisor!

  def index
    render json: Shopper.all
  end

  def show
    render json: @shopper, root: 'shopper'
  end

  def create
    # TODO: change default user_type, Changes city when the app grow up
    shopper = Shopper.new(shopper_params.merge(city_id: City.first.id))
    if shopper.save
      render(json: shopper, status: :created)
    else
      render(json: shopper.errors, status: :bad_request)
    end
  end

  def update
    if @shopper.update(shopper_params)
      render(json: @shopper)
    else
      render(json: @shopper.errors, status: :bad_request)
    end
  end

  def destroy
    @shopper.active = false
    @shopper.save
    render json: @shopper
  end


  private

  def shopper_params
    params.permit(:first_name, :last_name, :email, :identification, :address, :status,
                  :phone_number, :image, :latitude, :longitude, :active, :company_email, :shopper_type)
  end

  def set_supervisor
    @shopper = Shopper.find(params[:id])
  end
end
