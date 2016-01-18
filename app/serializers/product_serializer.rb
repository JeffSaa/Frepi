class ProductSerializer < ActiveModel::Serializer
  attributes :id, :reference_code, :name, :store_price, :frepi_price, :image,
             :available, :sales_count, :subcategory_id, :total_sold_frepi_price, :total_sold_store_price, :earnings

  has_one    :sucursal

  def sucursal
    object.sucursals.first
  end
end
