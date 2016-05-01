class  Api::V1::ProductsController < Api::V1::ApiController

  # Callbacks
  before_action :find_store_partner, :find_sucursals
  before_action :find_product, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]
  skip_before_action :authenticate_supervisor!

  def index
=begin
    categories = @sucursal.categories.uniq
    products = @sucursal.products
    subcategories = @sucursal.subcategories.uniq

    render(json: categories.as_json(include: {
                                      subcategories:  {
                                        include: { products: { except: [:created_at, :updated_at] }
                                        }, except: [:created_at, :updated_at] }
                                    }, except: [:created_at, :updated_at]))




    #categories.each do |category|
     # json = category.as_json
      #json[:subcategories] = subcategories.select { |e| e.category_id == category.id }.as_json
    response_subcategory = []
    subcategories.each do |subcategory|
      json = subcategory.as_json
      json[:products] = products.select { |e| e.subcategory_id == subcategory.id }
      response_subcategory.push << json
    end
    response = []

    categories.each do |category|
      json = category.as_json
      json[:subcategories] = response_subcategory.select { |e| e['category_id'] == category.id}
      response.push << json
    end
=end
    #render(json: Product.where(available: true), serializer: nil)
    render(json: Product.available.as_json(include: [:subcategory, :category]), serializer: nil)
  end

  def show
    render(json: @product)
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
    # TODO: Valid when the subcategory_id does not exist
    @product.assign_attributes(product_params)
    if @product.save
      render(json: @product)
    else
      render(json: { errors: @product.errors }, status: :bad_request)
    end
  end

  def destroy
    @product.available = false
    @product.save
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
    params.permit(:reference_code, :name, :store_price, :frepi_price, :image, :available, :sales_count, :subcategory_id, :size, :description, :iva)
  end
end
