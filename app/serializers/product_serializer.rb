class ProductSerializer < ActiveModel::Serializer
  attributes :id, :reference_code, :name, :store_price, :frepi_price, :image,
             :available, :sales_count, :description, :size

  has_one    :sucursal, :subcategory, :category
  
  def sucursal
    object.sucursals.first
  end

  def category
  	object.category
  end

end
