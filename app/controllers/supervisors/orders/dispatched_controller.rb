class Supervisors::Orders::DispatchedController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Order.where(active: true, status: 3).order(scheduled_date: :desc, expiry_time: :desc), each_serializer: SupervisorOrderSerializer
  end
end
