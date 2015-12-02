class ProductSerializer < ActiveModel::Serializer
  attributes :id, :reference_code, :name, :store_price, :frepi_price, :image,
             :available, :sales_count, :subcategory_id

  has_one    :sucursal_id

  def sucursal_id
    object.sucursal_ids.first
  end
end
