class OrdersProductSerializer < ActiveModel::Serializer
  attributes :quantity
  has_one :product
end
