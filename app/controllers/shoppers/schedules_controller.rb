class Shoppers::SchedulesController < ApplicationController

  skip_before_action :authenticate_user!, :require_administrator
  before_action :find_schedule, only: [:show, :update, :destroy]

  def index
    render json: current_shopper.schedules
  end

  def show
    render json: @schedule
  end

  def create
    schedule = current_shopper.schedules.build(params_shedules)
    if schedule.valid?
      current_shopper.save
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

    params[:start_hour] = params.delete(:startHour) if params[:startHour]
    params[:end_hour] = params.delete(:endHour) if params[:endHour]

    params.permit(:start_hour, :end_hour, :day)
  end

  def find_schedule
    begin
      @schedule = current_shopper.schedules.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end
end
