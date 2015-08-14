class SubcategoriesController < ApplicationController

  before_action :find_subcategory, except: [:index, :create]

  def index
    render(json: Subcategory.all, status: :ok)
  end

  def show
    @subcategory ? render(json: @subcategory, status: :ok) : head(:not_found)
  end

  def create
    # TODO: Valid when the category_id does not exist
    subcategory = Subcategory.new(subcategory_params)
    if subcategory.save
      render(json: subcategory, status: :created)
    else
      render(json: { errors: subcategory.errors }, status: :bad_request)
    end
  end

  def update
    # TODO: Valid when the category_id does not exist
    @subcategory.assign_attributes(subcategory_params)
    if @subcategory.save
      render(json: @subcategory, status: :accepted)
    else
      render(json: { errors: @subcategory.errors }, status: :bad_request)
    end
  end

  def destroy
    if @subcategory
      @subcategory.destroy
      render(json: @subcategory, status: :accepted)
    else
      head(:not_found)
    end
  end

  # Methods
  private
  def find_subcategory
    @subcategory = Subcategory.where(id: params[:id]).first
  end

  def subcategory_params
    params.permit(:name, :category_id)
  end
end