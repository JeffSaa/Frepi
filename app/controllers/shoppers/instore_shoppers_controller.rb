class Shoppers::InstoreShoppersController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Shopper.where(shopper_type: 'IN-STORE', active: true)
  end
end
