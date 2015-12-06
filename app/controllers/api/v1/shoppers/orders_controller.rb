class  Api::V1::Shoppers::OrdersController < Api::V1::ApiController

# NOTE: NOT for MVP version
=begin
  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_order, only: [:show, :update, :destroy]

  def index
    render json: current_shopper.orders
  end

  def show
    render json: @order
  end

  def create
    order = current_shopper.shoppers_orders.build(order_id: params[:order_id])
    if order.valid?
      # TODO: Change status received to accepted ?
      current_shopper.save
      render(json: order, status: :created)
    else
      render(json: { errors: order.errors }, status: :bad_request)
    end
  end

  def update
    @order.assign_attributes(params_order)
    if @order.save
      render(json: @order)
    else
      render(json: { errors: order.errors }, status: :bad_request)
    end
  end

  def destroy
    @order.delete_order
    @order.save
    render(json: @order)
  end

  private
  def find_order
    begin
      @order = current_shopper.orders.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def params_order
    params.permit(:status, :delivery_time)
  end
=end
end
