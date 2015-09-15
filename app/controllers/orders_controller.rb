class OrdersController < ApplicationController

  before_action :find_order, only: [:show, :update, :destroy]
  before_action :find_sucursal, only: [:create]
  skip_before_action :require_administrator

  def index
    # TODO: what happen if the user is admin, order active ?
    render json: current_user.orders.where(active: true)
  end

  def show
    render json: @order
  end

  def create
    # TODO: add products to the order
    order = current_user.orders.new(order_params)
    if order.save
      params[:products].each do |product|
        render(json: { error: "product with id: #{product[:id]} not found" }, status: :not_found) and return unless @sucursal.products.exists?(product[:id])

        order.orders_products.create!(product_id: product[:id], quantity: product[:quantity])
      end

      render(json: order, status: :created)
    else
      render(json: { errors: order.errors }, status: :bad_request)
    end
  end

  def update
    # TODO: update products in an order
  end

  def destroy
    @order.active = false
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
      p params
      params[:sucursal_id] = params.delete(:sucursalId)
      @sucursal = Sucursal.find(params[:sucursal_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def order_params
    params[:delivery_time] = params.delete(:deliveryTime)
    params.permit(:date, :sucursal_id, :active, :status, :delivery_time)
  end

end
