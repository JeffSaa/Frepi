class Api::V1::Administrator::Statistics::ProductsController < Api::V1::ApiController

  skip_before_action  :authenticate_supervisor!
  skip_before_action  :authenticate_user!, :require_administrator

  def index
    if params[:start_date] || params[:end_date]

      orders = Order.where("status > ? AND active = ?", 0, true).where("shopping_at >= ? AND shopping_at <= ?", params[:start_date], params[:end_date])
      products = Hash.new(0)

      orders.each do |order|
        order.orders_products.each { |order| products[order.product] += order.quantity }
      end

      products = products.sort_by { |product, quantity| product.sales_count = quantity; quantity }.reverse.to_h.keys

      render json: products, each_serializer: ProductSerializer
    else
      head(:bad_request)
    end
  end
end
