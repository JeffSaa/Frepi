class  Api::V1::Shoppers::ShoppersController < Api::V1::ApiController

  before_action      :set_shopper, only: [:show, :update, :destroy]
  skip_before_action :authenticate_supervisor!
  skip_before_action :authenticate_user!, :require_administrator, only: :index
  before_action      :administrador_supervisor, only: :index

  def index
    if params[:page]
      @shopper = Shopper.paginate(per_page: params[:per_page], page: params[:page])
      set_pagination_headers(:shopper)
      render json: @shopper
    else
      render json: { error: "param 'page' has not been found" }, status: :bad_request
    end
  end

  def show
    render json: @shopper, root: 'shopper'
  end

  def create
    # TODO: Changes city when the app grow up
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

  def set_shopper
    @shopper = Shopper.find(params[:id])
  end
end
