class  Api::V1::SchedulesController < Api::V1::ApiController

  skip_before_action :authenticate_supervisor!, :require_administrator
  before_action :find_order
  before_action :find_schedule, only: [:show, :update, :destroy]

  def index
    render json: @order.schedules
  end

  def show
    render json: @schedule
  end

  def create
    schedule = @order.schedules.build(params_shedules)
    if schedule.valid?
      @order.save
      render(json: schedule, status: :created)
    else
      render(json: { errors: schedule.errors }, status: :bad_request)
    end
  end

  def update
    @schedule.assign_attributes(params_shedules)

    if @schedule.save
      render(json: @schedule)
    else
      render(json: { errors: @schedule.errors }, status: :bad_request)
    end
  end

  def destroy
    @schedule.destroy
    render json: @schedule
  end

  private

  def params_shedules
    params.permit(:start_hour, :end_hour, :day)
  end

  def find_order
    begin
      @order = current_user.orders.find(params[:order_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_schedule
    begin
      @schedule =  @order.schedules.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end
end
