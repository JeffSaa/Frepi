class Shoppers::OrdersController < ApplicationController

  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_order, only: [:show, :update, :destroy]

  def index
    orders = Order.where(status: 0, active: true)
    render json: orders
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
