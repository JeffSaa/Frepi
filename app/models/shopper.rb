class Shopper < ActiveRecord::Base

  # Enumerators
  enum status: [:active, :idle]

  # Associations
  has_many :shoppers_orders
  has_many :shoppers_schedules
  has_many :orders, through: :shoppers_orders
  has_many :schedules,through: :shoppers_schedules
end
