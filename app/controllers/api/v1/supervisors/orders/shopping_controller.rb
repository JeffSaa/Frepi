class  Api::V1::Supervisors::Orders::ShoppingController < Api::V1::ApiController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    if params[:page]
      @orders = Order.where(active: true, status: 1).order(:scheduled_date, :expiry_time).paginate(per_page: params[:per_page], page: params[:page])
      set_pagination_headers(:orders)
      render json: @orders, each_serializer: SupervisorOrderSerializer
    else
      render json: { error: "param 'page' has not been found" }, status: :bad_request
    end
  end
end
