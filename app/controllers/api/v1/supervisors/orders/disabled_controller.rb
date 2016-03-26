class Api::V1::Supervisors::Orders::DisabledController < Api::V1::ApiController

  skip_before_action :authenticate_user!, :require_administrator
  
  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    @orders = Order.where(active: false).order(:scheduled_date, :expiry_time).paginate(per_page: params[:per_page], page: params[:page])
    set_pagination_headers(:orders)
    render json: @orders, each_serializer: SupervisorOrderSerializer
  end
end