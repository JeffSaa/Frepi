class Api::V1::Administrator::Statistics::ShoppersController < Api::V1::ApiController

  skip_before_action  :authenticate_supervisor!

  def index
    if params[:start_date] && params[:end_date] && params[:page]

      orders = Order.where("status > ? AND active = ?", 0, true).where("shopping_at >= ? AND shopping_at <= ?", params[:start_date], params[:end_date])
      shoppers = Hash.new(0)

      orders.each do |order|
        order.shoppers_order.each { |order| shoppers[order.shopper] += 1 }
      end

      shoppers = shoppers.sort_by { |shopper, counter| shopper.taken_orders_count = counter; counter }.reverse.to_h.keys

      @shoppers = WillPaginate::Collection.create(params[:page], params[:per_page], shoppers.length) do |pager|
        pager.replace shoppers[pager.offset, pager.per_page]
      end

      set_pagination_headers :shoppers
      render json: @shoppers, each_serializer: ShopperSerializer

    else
      render json: { error: "param 'page' or 'start_date' or 'end_date' has not been found" }, status: :bad_request
    end
  end
end
