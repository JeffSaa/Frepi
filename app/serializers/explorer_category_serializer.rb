class ExplorerCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  has_many   :subcategories, serializer: SubcategorySerializer
  has_many   :products

  def products
    object.products.last(5)
  end
end
