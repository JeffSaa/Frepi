class Order < ActiveRecord::Base

  # Enumerators
  enum status: %w[received delivering dispatched]

  # Associations
  belongs_to  :user, counter_cache: :counter_orders
  belongs_to  :sucursal
  has_one     :shopper, through: :shoppers_order
  has_many    :products, through: :orders_products
  has_many    :schedules, through: :orders_schedules
  has_one     :shoppers_order
  has_many    :orders_products
  has_many    :orders_schedules

  # Validations
  validates :user, :sucursal, :date, presence: true
  validates :status, inclusion: { in: %w(received delivering dispatched)}
  validates :active, inclusion: { in: [true, false] }
  validates_datetime :date

end
