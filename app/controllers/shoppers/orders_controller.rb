class Shoppers::OrdersController < ApplicationController

  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_order, only: [:show, :update, :destroy]

  def index
    #orders = Order.where(status: 0, active: true)
    # Users that have orders near of a latitude

    # REFACTOR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if params[:latitude] && params[:longitude]

      latitude = params[:latitude]
      longitude = params[:longitude]

      users = User.near([latitude, longitude], Shopper::DISTANCE,  units: :km).joins(:orders).where(orders: { active:true, status: 0} )
      orders = []

      users.map do |user|
        user.distance =  user.distance_to([latitude, longitude], :km)
        user.orders.where( { active:true, status: 0 } ).each { |order| orders << order }
      end

      render json: orders, root: :orders
    end
  end

  def show
    render json: @order
  end

  def create
  end

  def update
  end

  def destroy
    @order.delete_order
  end

  private
  def find_order
    begin
      @order = Order.where(status: 0, active: true).find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end
end
