class SubcategoriesController < ApplicationController

  before_action :find_category
  before_action :find_subcategory, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]
  skip_before_action :authenticate_shopper!

  def index
    render(json: @category.subcategories , status: :ok)
  end

  def show
    render(json: @subcategory, status: :ok)
  end

  def create
    subcategory = @category.subcategories.create(subcategory_params)
    if subcategory.save
      render(json: subcategory, status: :created)
    else
      render(json: { errors: subcategory.errors }, status: :bad_request)
    end
  end

  def update
    @subcategory.assign_attributes(subcategory_params)
    if @subcategory.save
      render(json: @subcategory)
    else
      render(json: { errors: @subcategory.errors }, status: :bad_request)
    end
  end

  def destroy
    @subcategory.destroy
    render(json: @subcategory)
  end

  # Methods
  private

  def find_category
    begin
      @category = Category.find(params[:category_id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def find_subcategory
    begin
      @subcategory = @category.subcategories.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def subcategory_params
    params.permit(:name)
  end
end