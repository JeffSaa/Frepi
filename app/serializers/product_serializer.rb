class ProductSerializer < ActiveModel::Serializer
  attributes :id, :reference_code, :name, :store_price, :frepi_price, :image, :available, :sales_count

  has_one :category

  def category
    object.category
  end
end
