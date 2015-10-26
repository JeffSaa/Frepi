class OrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date, :delivery_time, :sucursal
  has_many   :orders_products, :schedules
  has_one    :user
end
