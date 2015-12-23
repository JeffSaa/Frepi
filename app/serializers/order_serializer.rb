class OrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date, :delivery_time,
             :scheduled_date, :arrival_time, :expiry_time, :comment, :address, :shopping_at

  has_many :products

  def products
    object.orders_products
  end
end
