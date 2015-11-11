class SupervisorsController < ApplicationController

  before_action :set_supervisor, only: [:show, :update, :destroy]
  skip_before_action :authenticate_shopper!, only: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, except: [:index, :create]

  def index
    @supervisors = Supervisor.all

    render json: @supervisors
  end

  def show
    render json: @supervisor
  end

  def create
    @supervisor = Supervisor.new(supervisor_params.merge(city_id: City.first.id))

    if @supervisor.save
      render json: @supervisor, status: :created
    else
      render json: @supervisor.errors, status: :unprocessable_entity
    end
  end

  def update
    @supervisor = Supervisor.find(params[:id])

    if @supervisor.update(supervisor_params)
      render json: @supervisor
    else
      render json: @supervisor.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @supervisor.active = false
    @supervisor.save
    render json: @supervisor
  end


  # ------------------ Private ----------------- #
  private

  def set_supervisor
    @supervisor = Supervisor.find(params[:id])
  end

  def supervisor_params
    params.permit(:first_name, :last_name, :phone_numbre, :active, :address, :company_email, :personal_email, :image, :identification)
  end
end
