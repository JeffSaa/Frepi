class ExplorerCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :store_partner_id
  has_many   :subcategories, serializer: SubcategorySerializer
  has_many   :products

  def products
    object.products.availables.order("RANDOM()").limit(5)
  end
end
