class Supervisors::Orders::ReceivedController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Order.where(active: true, status: 0), each_serializer: SupervisorOrderSerializer
  end
end
