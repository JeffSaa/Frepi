class  Api::V1::Supervisors::Orders::ReceivedController < Api::V1::ApiController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Order.where(active: true, status: 0).order(:scheduled_date, :expiry_time), each_serializer: SupervisorOrderSerializer
  end
end
