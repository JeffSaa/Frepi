class CitiesController < ApplicationController

  before_action :find_country, :find_state
  before_action :find_city, except: [:index, :create]
  skip_before_action :authenticate_shopper!

  def index
    render json: @state.cities.all
  end

  def show
    render json: @city
  end

  def create
    city = @state.cities.create(params_city)
    if city.save
      render(json: city, status: :created)
    else
      render(json: { errors: city.errors }, status: :bad_request)
    end
  end

  def update
    @city.assign_attributes(params_city)
    if @city.save
      render(json: @city)
    else
      render(json: { errors: @city.errors }, status: :bad_request)
    end
  end

  def destroy
    @city.destroy
    render json: @city
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
      @state = @country.states.find(params[:state_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_city
    begin
      @city = @state.cities.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def params_city
    params.permit(:name)
  end
end
