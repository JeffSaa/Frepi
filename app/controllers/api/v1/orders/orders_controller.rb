class  Api::V1::Orders::OrdersController < Api::V1::ApiController

  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_order, only: [:show, :update, :destroy]

  def index
    if params[:latitude] && params[:longitude]

      latitude = params[:latitude]
      longitude = params[:longitude]

      users = User.near([latitude, longitude], Shopper::DISTANCE, units: :km).joins(:orders).where(orders: { active:true, status: 0 } )

      orders = []

      users.each do |user|
       user.distance =  user.distance_to([latitude, longitude], :km)
      end

      users = users.sort_by { |x| x.distance }

      users.each do |user|
        user.orders.where( { active:true, status: 0 } ).each { |order| orders << order }
      end

      render json: orders
    end
  end

  def show
    render json: @order
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
