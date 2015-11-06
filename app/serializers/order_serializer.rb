class OrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date, :delivery_time
  has_many   :orders_products, :schedules
end
