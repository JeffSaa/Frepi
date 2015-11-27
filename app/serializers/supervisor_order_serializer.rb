class SupervisorOrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date, :delivery_time,
             :scheduled_date, :arrival_time, :expiry_time, :comment, :address

  has_many :products
  has_one  :user
  has_many :shopper

  def products
    object.orders_products
  end
end
