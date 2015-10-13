class Shoppers::OrdersController < ApplicationController

  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_order, only: [:show, :update, :destroy]

  def index
    establish_headers
    render json: current_shopper.orders
  end

  def show
    render json: @order
  end

  def create
    order = current_shopper.shoppers_orders.build(order_id: params[:orderId])
    if order.valid?
      # TODO: Change status received to accepted ?
      #find_order(params[:order_id])
      current_shopper.save
      render(json: order, status: :created)
    else
      render(json: { errors: order.errors }, status: :bad_request)
    end
  end

  def update
    @order.assign_attributes(params_order)
    if @order.save
      establish_headers
      render(json: @order)
    else
      render(json: { errors: order.errors }, status: :bad_request)
    end
  end

  def destroy
    establish_headers
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
    params[:delivery_time] = params.delete(:deliveryTime) if params[:deliveryTime]
    params.permit(:status, :delivery_time)
  end

  def establish_headers
    header = current_shopper.generate_token
    response.headers['access-token'] = header["access-token"]
    response.headers['token-type'] = header["token-type"]
    response.headers['client'] = header["client"]
    response.headers['uid'] = header["uid"]
    response.headers['expiry'] = header["expiry"]
  end
end
