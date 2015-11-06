class ExplorerCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  has_many   :subcategories, serializer: ExplorerSubcategorySerializer
  has_many   :products

  def subcategories
    object.subcategories.distinct
  end

  def products
    object.products.last(5)
  end
end
