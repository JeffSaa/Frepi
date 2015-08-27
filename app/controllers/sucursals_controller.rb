class SucursalsController < ApplicationController

  before_action :find_store_partner
  before_action :find_sucursals, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]

  def index
    render(json: @store_partner.sucursals)
  end

  def show
    render(json: @sucursal)
  end

  def create
    sucursal = @store_partner.sucursals.build(sucursals_params)
    if sucursal.save
      render(json: sucursal, status: :created)
    else
      render(json: { errors: sucursal.errors }, status: :bad_request)
    end
  end

  def update
    @sucursal.assign_attributes(sucursals_params)
    if @sucursal.save
      render(json: @sucursal, status: :accepted)
    else
      render(json: { errors: @sucursal.errors }, status: :bad_request)
    end
  end

  def destroy
    @sucursal.destroy
    render(json: @sucursal)
  end

  # Methods
  private

  def find_store_partner
    begin
      @store_partner = StorePartner.find(params[:store_partner_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_sucursals
    begin
      @sucursal = @store_partner.sucursals.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def sucursals_params
    params.permit(:name, :manager_full_name, :manager_email, :manager_phone_number,
                  :phone_number, :address, :latitude, :longitude)
  end
end
