class ProductSerializer < ActiveModel::Serializer
  attributes :reference_code, :name, :store_price, :frepi_price, :image, :available, :sales_count, :subcategory_id
end
