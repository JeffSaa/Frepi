class Api::V1::Administrator::Statistics::ProductsController < Api::V1::ApiController

  skip_before_action :authenticate_supervisor!

  def index
    if params[:start_date] && params[:end_date] && params[:page]

      orders = Order.where("status > ? AND active = ?", 0, true).where("shopping_at >= ? AND shopping_at <= ?", params[:start_date], params[:end_date])
      products = Hash.new(0)

      orders.each do |order|
        order.orders_products.each { |order| products[order.product] += order.quantity }
      end

      products = products.sort_by { |product, quantity| product.sales_count = quantity; quantity }.reverse.to_h.keys

      @products = WillPaginate::Collection.create(params[:page], params[:per_page], products.length) do |pager|
        pager.replace products[pager.offset, pager.per_page]
      end

      set_pagination_headers :products
      render json: @products, each_serializer: ProductSerializer

    else
      render json: { error: "param 'page' or 'start_date' or 'end_date' has not been found" }, status: :bad_request
    end
  end
end
