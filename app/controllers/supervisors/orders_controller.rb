class Supervisors::OrdersController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_order, only: [:show, :update, :destroy]

  def index
    #received = Order.where(active: true, status: 0).map { |order| SupervisorOrderSerializer.new(order) }
    render json: Order.all, each_serializer: SupervisorOrderSerializer
  end

  def show
    render json: @order, serializer: SupervisorOrderSerializer
  end

  def create
    shopper_order = ShoppersOrder.new(orders_shopper_params)
    if shopper_order.valid?
      order = shopper_order.order
      order.status = 1
      order.save
      shopper_order.save
      render json: shopper_order.order, serializer: SupervisorOrderSerializer, status: :created
    else
      render(json: { errors: shopper_order.errors }, status: :bad_request)
    end
  end

  def update
    if @order.update(order_params)
      if params[:products]
        response = @order.products_not_acquired(params[:products])
        if  response == true
          render json: @order, serializer: SupervisorOrderSerializer
        else
          render json: response, status: :unprocessable_entity
        end
      else
        render json: @order, serializer: SupervisorOrderSerializer
      end
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def destroy
  end

  # --------------------  Private ------------------- #
  private
  def find_order
    begin
      @order = Order.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def orders_shopper_params
    params.permit(:shopper_id, :order_id)
  end

  def order_params
    params.permit(:status)
  end

end
