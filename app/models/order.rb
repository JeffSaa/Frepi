class Order < ActiveRecord::Base

  # Enumerators
  enum status: [:received, :delivering, :dispatched]

  # Associations
  belongs_to  :user
  belongs_to  :sucursal
  has_many    :products, through: :orders_products
  has_many    :orders_products
end
