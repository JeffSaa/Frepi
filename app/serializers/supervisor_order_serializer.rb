class SupervisorOrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date,
             :scheduled_date, :arrival_time, :expiry_time, 
             :comment, :address, :shopping_at, :notification_email,
             :telephone, :discount

  has_many :products
  has_one  :user
  has_many :shopper

  def products
    object.orders_products
  end
end
