class ProductsController < ApplicationController

  before_action :find_product, except: [:index, :create]

  def index
    render(json: Product.all, status: :ok)
  end

  def show
    @product ? render(json: @product, status: :ok) : head(:not_found)
  end

  def create
    # TODO: Valid when the subcategory_id does not exist
    product = Product.new(product_params)
    if product.save
      render(json: product, status: :created)
    else
      render(json: { errors: product.errors }, status: :bad_request)
    end
  end

  def update
    # TODO: Valid when the subcategory_id does not exist
    @product.assign_attributes(product_params)
    if @product.save
      render(json: @product, status: :accepted)
    else
      render(json: { errors: @product.errors }, status: :bad_request)
    end
  end

  def destroy
    if @product
      @product.destroy
      render(json: @product, status: :accepted)
    else
      head(:not_found)
    end
  end

  # Methods
  private
  def find_product
    @product = Product.where(id: params[:id]).first
  end

  def product_params
    params.permit(:reference_code, :name, :store_price, :frepi_price, :image, :available, :sales_count, :subcategory_id)
  end

end
