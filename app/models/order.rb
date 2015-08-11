class Order < ActiveRecord::Base

  # Enumerators
  enum status: [:received, :delivering, :dispatched]

  # Associations
  belongs_to  :user
  belongs_to  :sucursal
  has_one     :shopper, through: :shoppers_order
  has_many    :products, through: :orders_products
  has_many    :schedules, through: :orders_schedules
  has_one     :shoppers_order
  has_many    :orders_products
  has_many    :orders_schedules

end
