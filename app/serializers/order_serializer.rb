class OrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date,
             :scheduled_date, :arrival_time, :expiry_time, 
             :comment, :address, :shopping_at, :notification_email,
             :telephone, :discount, :payment

  has_many :products

  def products
    object.orders_products
  end
end
