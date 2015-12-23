class StatisticsSerializer < ActiveModel::Serializer

  attributes :products

  def products
    object.map do |key, value|
      product = Product.find(key)
      product.sales_count = value
      product
    end
  end

end
