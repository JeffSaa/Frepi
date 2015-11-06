class ExplorerSubcategorySerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name
  has_many  :products

  def products
    object.products.last(5)
  end
end
