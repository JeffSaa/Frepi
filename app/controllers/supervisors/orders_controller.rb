class Supervisors::OrdersController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_order, only: [:show, :update, :destroy]
  before_action :find_shopper, only: :create

  def index
    #received = Order.where(active: true, status: 0).map { |order| SupervisorOrderSerializer.new(order) }
    render json: order.all, each_serializer: SupervisorOrderSerializer
  end

  def show
  end

  def create
    shopper_order = ShoppersOrder.new(order_params)
    if shopper_order.valid?
      order = shopper_order.order
      order.status = 1
      order.save
      shopper_order.save
      render(json: shopper_order.order, status: :created)
    else
      render(json: { errors: shopper_order.errors }, status: :bad_request)
    end
  end

  def update
  end

  def destroy
  end

  private
  def find_order
    begin
      @order = current_user.orders.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_shopper
    begin
      @shopper = Shopper.find(params[:shopper_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def order_params
    params.permit(:order_id, :shopper_id)
  end

end
