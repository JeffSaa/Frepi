class Api::V1::Explorer::ProductsController < Api::V1::ApiController
  
  skip_before_action :authenticate_supervisor!, :require_administrator, :authenticate_user!
  before_action :find_category

  def index
  	render json: @category.products.available, each_serializer: ExplorerProductsCategorySerializer
  end

  private
	  def find_category
	    begin
	      @category = Category.find(params[:category_id])
	    rescue => e
	      render(json: { error: e.message }, status: :not_found)
	    end
	  end
end