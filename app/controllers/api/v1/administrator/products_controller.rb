class Api::V1::Administrator::ProductsController < Api::V1::ApiController

  skip_before_action :authenticate_supervisor!
  before_action :find_sucursal, only: :create
  before_action :find_product, only: [:show, :update, :destroy]

  def index
    render json: Product.all
  end

  def show
    render json: @product
  end

  def create
    product = @sucursal.products.create(product_params)
    if product.save
      render(json: product, root: false, status: :created)
    else
      render(json: { errors: product.errors }, status: :bad_request)
    end
  end

  def update
    @product.assign_attributes(product_params)
    if @product.save
      render(json: @product)
    else
      render(json: { errors: @product.errors }, status: :bad_request)
    end
  end

  def destroy
    @product.destroy
    render(json: @product)
  end

  private
    # Methods
    def find_sucursal
      begin
        @sucursal = Sucursal.find(params[:sucursal_id])
      rescue => e
        render(json: { error: e.message }, status: :not_found)
      end
    end

    def find_product
      begin
        @product = Product.find(params[:id])
      rescue => e
        render(json: { error: e.message }, status: :not_found)
      end
    end

    def product_params
      params.permit(:reference_code, :name, :store_price, :frepi_price, :image, :available, :sales_count, :subcategory_id)
    end
end
