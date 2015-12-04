class Shoppers::DeliveryShoppersController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Shopper.where(shopper_type: 1, active: true)
  end
end
