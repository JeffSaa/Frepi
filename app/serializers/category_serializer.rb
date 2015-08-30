class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  has_many :subcategories
end
