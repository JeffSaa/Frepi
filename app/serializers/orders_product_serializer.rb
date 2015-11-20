class OrdersProductSerializer < ActiveModel::Serializer
  attributes :quantity, :comment
  has_one    :product

  def product
    object.product
  end
end
