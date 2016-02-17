class Api::V1::Search::ProductsController < ApplicationController
  skip_before_action :authenticate_supervisor!, :require_administrator, :authenticate_user!

  def index
    if params[:search]
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      @products = Product.where('escaped_name ILIKE ?', "%#{params[:search].downcase}%").paginate(per_page: per_page, page: page)
      set_pagination_headers :products
      render json: @products, serializer: nil
    end
  end
end
