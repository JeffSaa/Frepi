class Api::V1::Search::ProductsController < ApplicationController
  skip_before_action :authenticate_supervisor!, :require_administrator, :authenticate_user!

  def index
    if params[:search]
      products = Product.where('escaped_name ILIKE ?', "%#{params[:search].downcase}%")#.offset(m).limit(10)
      render json: products, serializer: nil
    end
  end
end
