class  Api::V1::ExploreCategoriesController < Api::V1::ApiController
  skip_before_action :authenticate_supervisor!, :require_administrator, :authenticate_user!
  before_action      :find_store_partner

  def index
    render json: @store_partner.categories.order(:id).distinct, each_serializer: ExplorerCategorySerializer
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
