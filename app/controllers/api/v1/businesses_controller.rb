class Api::V1::BusinessesController <  Api::V1::ApiController
  # Callbacks
  skip_before_action :authenticate_user!
  skip_before_action :require_administrator
  skip_before_action :authenticate_supervisor!

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    businesses =
                  if params[:start_with].present?
                     Business.start_with(params[:start_with])
                   elsif params[:nit].present?
                     Business.nit(params[:nit]).paginate(page: page, per_page: per_page)
                   else
                     Business.all.paginate(page: params[:page], per_page: 10)
                   end
    render json: businesses, status: :created
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
