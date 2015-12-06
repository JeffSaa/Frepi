class Supervisors::Orders::DeliveringController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Order.where(active: true, status: 2).order(:scheduled_date, :expiry_time), each_serializer: SupervisorOrderSerializer
  end
end
