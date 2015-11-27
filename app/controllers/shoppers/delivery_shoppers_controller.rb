class Shoppers::DeliveryShoppersController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Shopper.where(shopper_type: 'DELIVERY', active: true)
  end
end
