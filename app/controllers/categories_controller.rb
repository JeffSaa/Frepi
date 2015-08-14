class CategoriesController < ApplicationController

  before_action :find_category, except: [:index, :create]

  def index
    render(json: Category.all, status: :ok)
  end

  def show
    @category ? render(json: @category, status: :ok) : head(:not_found)
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
      render(json: @category, status: :accepted)
    else
      render(json: { errors: @category.errors }, status: :bad_request)
    end
  end

  def destroy
    if @category
      @category.destroy
      render(json: @category, status: :accepted)
    else
      head(:not_found)
    end
  end

  # Methods
  private
  def find_category
    @category = Category.where(id: params[:id]).first
  end

  def category_params
    params.permit(:name, :description)
  end
end
