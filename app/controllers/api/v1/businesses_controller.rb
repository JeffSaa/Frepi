class Api::V1::BusinessesController <  Api::V1::ApiController
  # Callbacks
  skip_before_action :authenticate_user!
  skip_before_action :require_administrator
  skip_before_action :authenticate_supervisor!

  def index
  end

  def show
  end

  def create
    business = Business.new(business_params)
    if business.save
      render json: business, status: :created
    else
      render json: business.errors, status: :unprocessable_entity
    end
  end

  def update
  end

  def destroy
  end

  private
  def business_params
    params.permit(:nit, :name, :address)
  end
end
