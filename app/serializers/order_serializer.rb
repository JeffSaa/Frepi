class OrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date, :delivery_time, :scheduled_date, :arrival_time, :expiry_time

  # Change key of relation
  has_many   :orders_products
end
