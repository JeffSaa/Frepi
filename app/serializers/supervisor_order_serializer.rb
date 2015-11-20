class SupervisorOrderSerializer < ActiveModel::Serializer
  attributes :id, :active, :status, :total_price, :date, :delivery_time, :scheduled_date, :arrival_time, :expiry_time

  has_many :products
  has_one :user
  has_one :shopper

  def products
    object.orders_products
  end
end
