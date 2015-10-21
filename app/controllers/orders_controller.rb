class OrdersController < ApplicationController

  before_action :find_order, only: [:show, :update, :destroy]
  before_action :find_sucursal, only: [:create]
  skip_before_action :require_administrator, :authenticate_shopper!

  def index
    # TODO: what happen if the user is admin, order active ?
    render json: current_user.orders.where(active: true)
  end

  def show
    render json: @order
  end

  def create
    order = current_user.orders.new(order_params)
    if order.valid? && order.buy(params[:products])
      order.save
      render(json: order, status: :created)
    else
      render(json: { errors: order.errors }, status: :bad_request)
    end
  end

  def update
    @order.assign_attributes(order_params)

    if @order.valid?
      @order.save
      @order.update_products(params[:products])
      render(json: @order)
    else
      render(json: { errors: @order.errors }, status: :bad_request)
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
      @order = current_user.orders.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_sucursal
    begin
      @sucursal = Sucursal.find(params[:sucursal_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def order_params
    params.permit(:sucursal_id, :status, :delivery_time)
  end

end
