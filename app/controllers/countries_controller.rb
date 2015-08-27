class CountriesController < ApplicationController

  before_action :find_country, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]

  def index
    render json: Country.all
  end

  def show
    render json: @country
  end

  def create
    country = Country.new(params_country)
    if country.save
      render(json: country, status: :created)
    else
      render(json: { errors: country.errors }, status: :bad_request)
    end
  end

  def update
    @country.assign_attributes(params_country)
    if @country.save
      render(json: @country, status: :created)
    else
      render(json: { errors: @country.errors }, status: :bad_request)
    end
  end

  def destroy
    @country.destroy
    render json: @country
  end


  # Methods
  private

  def find_country
    begin
      @country = Country.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def params_country
    params.permit(:name)
  end
end
