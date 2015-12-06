class  Api::V1::Shoppers::InstoreShoppersController < Api::V1::ApiController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Shopper.where(shopper_type: 0, active: true)
  end
end
