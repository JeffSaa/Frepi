class  Api::V1::Shoppers::DeliveryShoppersController < Api::V1::ApiController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Shopper.where(shopper_type: 1, active: true)
  end
end
