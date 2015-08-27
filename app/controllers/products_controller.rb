class ProductsController < ApplicationController

  # Callbacks
  before_action :find_store_partner, :find_sucursals
  before_action :find_product, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]

  def index
    categories = @sucursal.categories.uniq
    render(json: categories.as_json(include: {
                                      subcategories:  {
                                        include: { products: { except: [:created_at, :updated_at] }
                                        }, except: [:created_at, :updated_at] }
                                    }, except: [:created_at, :updated_at]))
  end

  def show
    render(json: @product)
  end

  def create
    product = @sucursal.products.create(product_params)
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
      render(json: @product)
    else
      render(json: { errors: @product.errors }, status: :bad_request)
    end
  end

  def destroy
    @product.destroy
    render(json: @product)
  end

  # Methods
  private

  def find_store_partner
    begin
      @store_partner = StorePartner.find(params[:store_partner_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_sucursals
    begin
      @sucursal = @store_partner.sucursals.find(params[:sucursal_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_product
    begin
      @product = @sucursal.products.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def product_params
    params.permit(:reference_code, :name, :store_price, :frepi_price, :image, :available, :sales_count, :subcategory_id)
  end
end
