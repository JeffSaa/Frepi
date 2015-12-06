class  Api::V1::SupervisorsController < Api::V1::ApiController

  before_action      :set_supervisor, only: [:show, :update, :destroy]
  skip_before_action :authenticate_supervisor!

  def index
    render json: Supervisor.all
  end

  def show
    render json: @supervisor
  end

  def create
    supervisor = Supervisor.new(supervisor_params.merge(city_id: City.first.id))

    if supervisor.save
      render json: supervisor, status: :created
    else
      render json: supervisor.errors, status: :unprocessable_entity
    end
  end

  def update
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
    params.permit(:first_name, :last_name, :phone_number, :active, :address, :company_email, :email, :image, :identification, :password, :password_confirmation)
  end
end
