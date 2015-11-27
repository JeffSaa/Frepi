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
      shopper = Shopper.find(params[:shopper_id])
      shopper.shopper_type  == 'IN-STORE' ? order.status = 1 : order.status = 2
      order.save
      shopper_order.save
      render json: shopper_order.order, serializer: SupervisorOrderSerializer, status: :created
    else
      render(json: { errors: shopper_order.errors }, status: :bad_request)
    end
  end

  def update
    if @order.update(order_params)
      if params[:products] || params[:shoppers]
        response_product = @order.products_not_acquired(params[:products])
        response_shopper = @order.updated_shopper(params[:shoppers])
        if response_product || response_shopper
          render json: response_product, status: :unprocessable_entity and return if response_product
          render json: response_shopper, status: :unprocessable_entity and return if response_shopper
        else
          render json: @order, serializer: SupervisorOrderSerializer
        end
      else
        render json: @order, serializer: SupervisorOrderSerializer
      end
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @order.status = 0
    @orde.shoppers_order.destroy_all
    @order.save
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
