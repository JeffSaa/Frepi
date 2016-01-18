class Api::V1::Administrator::Statistics::EarningsController < Api::V1::ApiController

  skip_before_action  :authenticate_supervisor!
  skip_before_action :authenticate_user!, :require_administrator


  def index

    if params[:start_date] && params[:end_date] && params[:page]

      orders = Order.where("status > ? AND active = ?", 0, true).where("shopping_at >= ? AND shopping_at <= ?", params[:start_date], params[:end_date])
      products = Hash.new(0)

      orders.each do |order|
        order.orders_products.each { |order| products[order.product] += order.quantity }
      end

      @sucursals = {}

      products.each do |product, quantity|
        @sucursals[product.sucursals.first.id] = product.sucursals.first if @sucursals[product.sucursals.first.id].nil?
        @sucursals[product.sucursals.first.id].total_sold_frepi_price += product.frepi_price * quantity
        @sucursals[product.sucursals.first.id].total_sold_store_price += product.store_price * quantity
        @sucursals[product.sucursals.first.id].earnings += (product.frepi_price - product.store_price) * quantity
      end

      @sucursals = @sucursals.values.sort_by { |sucursal| sucursal.earnings }.reverse

      @sucursals = WillPaginate::Collection.create(params[:page], params[:per_page], @sucursals.length) do |pager|
        pager.replace @sucursals[pager.offset, pager.per_page]
      end

      set_pagination_headers :sucursals
      render json: @sucursals, each_serializer: SucursalSerializer, serializer_params: { show: true }

    else
      render json: { error: "param 'page' or 'start_date' or 'end_date' has not been found" }, status: :bad_request
    end
  end
end