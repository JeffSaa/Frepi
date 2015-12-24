class Api::V1::Administrator::Statistics::ProductsController < Api::V1::ApiController

  skip_before_action  :authenticate_supervisor!
  skip_before_action  :authenticate_user!, :require_administrator

  def index
    OrdersWorker.perform_async
    if params[:start_date] || params[:end_date]

      orders = Order.where("status > ? AND active = ?", 0, true ).where("shopping_at >= ? AND shopping_at <= ?", params[:start_date], params[:end_date])
      products = Hash.new(0)
      orders.each do |order|
        quantities = Hash.new(0)
        order.orders_products.each { |order| quantities[order.product_id] += order.quantity }

        quantities.each { |product, quantity|  products[product] += quantity }
      end

      render json: products, serializer: StatisticsSerializer
    end
  end
end
