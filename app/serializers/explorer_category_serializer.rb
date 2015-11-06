class ExplorerCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  has_many   :subcategories, serializer: ExplorerSubcategorySerializer

  def subcategories
    object.subcategories.distinct
  end
end
