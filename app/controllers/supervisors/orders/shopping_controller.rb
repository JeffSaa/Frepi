class Supervisors::Orders::ShoppingController < ApplicationController
   skip_before_action :authenticate_user!, :require_administrator

  def index
    render json: Order.where(active: true, status: 1), each_serializer: SupervisorOrderSerializer
  end
end
