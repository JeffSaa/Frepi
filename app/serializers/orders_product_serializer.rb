class OrdersProductSerializer < ActiveModel::Serializer
  attributes :quantity, :comment, :acquired
  has_one    :product

  def product
    object.product
  end
end
