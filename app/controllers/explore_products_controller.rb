class ExploreProductsController < ApplicationController

  skip_before_action :authenticate_shopper!, :require_administrator, :authenticate_user!
  before_action :find_subcategory

  def index
    render json: @subcategory.products
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
