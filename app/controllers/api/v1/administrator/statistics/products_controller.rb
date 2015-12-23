class Api::V1::Administrator::Statistics::ProductsController < Api::V1::ApiController

  skip_before_action  :authenticate_supervisor!
  skip_before_action  :authenticate_user!, :require_administrator

  def index
    if params[:start_date] || params[:end_date]
      orders = Order.where("status > ? AND active = ?", 0, true )#.where("shopping_at >= ? AND shopping_at <= ?", params[:start_date], params[:end_date])
      #quantities = orders.map { |order| order.orders_products.quantity }
      render json: orders
    end
  end
end
