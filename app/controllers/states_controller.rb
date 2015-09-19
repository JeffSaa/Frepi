class StatesController < ApplicationController

  before_action :find_country
  before_action :find_state, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]

  def index
    render json: @country.states.all
  end

  def show
    render json: @state
  end

  def create
    state = @country.states.create(params_state)
    if state.save
      render(json: state, status: :created)
    else
      render(json: { errors: state.errors }, status: :bad_request)
    end
  end

  def update
    @state.assign_attributes(params_state)
    if @state.save
      render(json: @state)
    else
      render(json: { errors: @state.errors }, status: :bad_request)
    end
  end

  def destroy
    @state.destroy
    render json: @state
  end


  # Methods
  private

  def find_country
    begin
      @country = Country.find(params[:country_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_state
    begin
      @state = @country.states.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def params_state
    params.permit(:name)
  end
end
