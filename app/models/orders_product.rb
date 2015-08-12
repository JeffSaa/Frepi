class OrdersProduct < ActiveRecord::Base

  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :order, :product, presence: true
end
