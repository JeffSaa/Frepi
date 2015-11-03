class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  has_many   :subcategories

  def subcategories
    object.subcategories.distinct
  end
end
