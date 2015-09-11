class OrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :date, :delivery_time, :sucursal
  has_many   :orders_products
end
