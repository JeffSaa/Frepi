class  Api::V1::Supervisors::OrdersController < Api::V1::ApiController
  skip_before_action :authenticate_user!, :require_administrator, :authenticate_supervisor!
  before_action :find_order, only: [:show, :update, :destroy]
  before_action :administrador_supervisor

  def index
    #received = Order.where(active: true, status: 0).map { |order| SupervisorOrderSerializer.new(order) }
    if params[:page]
      @orders = Order.where(active: true).order(:scheduled_date, :expiry_time).paginate(per_page: params[:per_page], page: params[:page])
      set_pagination_headers(:orders)
      render json: @orders, each_serializer: SupervisorOrderSerializer
    else
      render json: { error: "param 'page' has not been found" }, status: :bad_request
    end
  end

  def show
    render json: @order, serializer: SupervisorOrderSerializer
  end

  def create
    shopper_order = ShoppersOrder.new(orders_shopper_params)
    if shopper_order.valid?
      order = shopper_order.order
      shopper = Shopper.find(params[:shopper_id])
      if shopper.shopper_type  == 'IN-STORE'
        order.status = 1
      else
        order.status = 2
      end
      order.save
      shopper_order.save
      render json: shopper_order.order, serializer: SupervisorOrderSerializer, status: :created
    else
      render(json: { errors: shopper_order.errors }, status: :bad_request)
    end
  end

  def update
    if params[:products] || params[:shoppers] || params[:status]
      response_product = @order.products_not_acquired(params[:products])
      response_shopper = @order.updated_shopper(params[:shoppers])
      response_status = @order.assign_attributes(status: params[:status]) if params[:status]
      if response_product || response_shopper || !@order.valid?
        render json: response_product, status: :unprocessable_entity and return if response_product
        render json: response_shopper, status: :unprocessable_entity and return if response_shopper
        render json: @order.errors, status: :unprocessable_entity and return unless @order.valid?
      else
        @order.save
        render json: @order, serializer: SupervisorOrderSerializer
      end
    end
  end

  def destroy
    @order.status = 0
    @order.shoppers_order.destroy_all
    @order.save
  end

  # --------------------  Private ------------------- #
  private
  def find_order
    begin
      @order = Order.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def orders_shopper_params
    params.permit(:shopper_id, :order_id)
  end

  def order_params
    params.permit(:status)
  end

end
