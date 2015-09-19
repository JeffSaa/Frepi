class StorePartnersController < ApplicationController

  before_action :find_store_partner, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]

  def index
    render(json: StorePartner.all, status: :ok)
  end

  def show
    @store_partner ? render(json: @store_partner, status: :ok) : head(:not_found)
  end

  def create
    store_partner = StorePartner.new(store_partner_params)
    if store_partner.save
      render(json: store_partner, status: :created)
    else
      render(json: { errors: store_partner.errors }, status: :bad_request)
    end
  end

  def update
    @store_partner.assign_attributes(store_partner_params)
    if @store_partner.save
      render(json: @store_partner)
    else
      render(json: { errors: @store_partner.errors }, status: :bad_request)
    end
  end

  def destroy
    if @store_partner
      @store_partner.destroy
      render(json: @store_partner, status: :accepted)
    else
      head(:not_found)
    end
  end

  # Methods
  private
  def find_store_partner
    @store_partner = StorePartner.where(id: params[:id]).first
  end

  def store_partner_params
    params.permit(:name, :nit, :description, :logo)
  end
end
