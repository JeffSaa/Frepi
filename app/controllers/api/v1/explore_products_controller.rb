class  Api::V1::ExploreProductsController < Api::V1::ApiController

  skip_before_action :authenticate_supervisor!, :require_administrator, :authenticate_user!
  before_action :find_subcategory

=begin
  def index
    if params[:per_page] && params[:page]
      @products = @subcategory.products.paginate(per_page: params[:per_page], page: params[:page])
      set_pagination_headers(:products)
      render json: @products
    else
      render json: { error: "params 'per_page' and 'page' has been not found" }, status: :bad_request
    end
  end
=end

  def index
    render json: @subcategory.products.where(available: true).order(:name)
  end

  private
  def find_subcategory
    begin
      @subcategory = Subcategory.find(params[:subcategory_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end
end
