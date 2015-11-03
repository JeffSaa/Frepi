class ExploreCategoriesController < ApplicationController
  skip_before_action :authenticate_shopper!, :require_administrator, :authenticate_user!
  before_action :find_store_partner

  def index
    render json: @store_partner.categories.distinct
  end

  private
  def find_store_partner
    begin
      @store_partner = StorePartner.find(params[:store_partner_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end
end
