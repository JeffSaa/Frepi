class SubcategorySerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name

  has_many :products
end
