class ExplorerProductsCategorySerializer < ActiveModel::Serializer
    attributes :id, :reference_code, :name, :store_price, :frepi_price, :image,
               :available, :sales_count, :subcategory_id
end
