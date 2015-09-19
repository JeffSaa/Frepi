class ProductSerializer < ActiveModel::Serializer
  attributes :id, :reference_code, :name, :store_price, :frepi_price, :image, :available, :sales_count

  has_one :category
  has_one :subcategory

  def category
    object.category
  end

  def subcategory
    object.subcategory
  end

end
