class CategoriesController < ApplicationController

  before_action :find_category, except: [:index, :create]
  skip_before_action :authenticate_user!, :require_administrator, only: [:index, :show]
  skip_before_action :authenticate_shopper!

  def index
    render(json: Category.all)
  end

  def show
    render(json: @category)
  end

  def create
    category = Category.new(category_params)
    if category.save
      render(json: category, status: :created)
    else
      render(json: { errors: category.errors }, status: :bad_request)
    end
  end

  def update
    @category.assign_attributes(category_params)
    if @category.save
      render(json: @category)
    else
      render(json: { errors: @category.errors }, status: :bad_request)
    end
  end

  def destroy
    @category.destroy
    render(json: @category)
  end

  private

  # Methods
  def find_category
    begin
      @category = Category.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def category_params
    params.permit(:name, :description)
  end
end
