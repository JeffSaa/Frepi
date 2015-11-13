class OrdersController < ApplicationController

  before_action :find_order, only: [:show, :update, :destroy]
  skip_before_action :require_administrator, :authenticate_supervisor!

  def index
    render json: current_user.orders.where(active: true)
  end

  def show
    render json: @order
  end

  def create
    new_order = Order.buy(current_user, params[:products])
    if new_order
      new_order.assign_attributes(params_shedules)
      if new_order.valid?
        new_order.save
        render(json: new_order, status: :created)
      else
        render(json: { errors: new_order.errors }, status: :bad_request)
      end
    else
      render(json: { errors: 'Product not found' }, status: :bad_request)
    end
  end

  def update
    order_update = @order.update_products(params[:products])
    if order_update
      order_update.assign_attributes(params_shedules)
      if order_update.valid?
        order_update.save
        render(json: order_update)
      else
        render(json: { errors: order_update.errors }, status: :bad_request)
      end
    else
      render(json: { errors: 'Product not found' }, status: :bad_request)
    end
  end

  def destroy
    @order.delete_order
    @order.save
    render(json: @order)
  end

  # ---------------------- Private -------------------------- #
  private
  def find_order
    begin
      @order = current_user.orders.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def params_shedules
    params.permit(:expiry_time, :arrival_time, :scheduled_date)
  end

end
