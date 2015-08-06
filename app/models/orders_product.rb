class OrdersProduct < ActiveRecord::Base

  # Associations
  belongs_to :order
  belongs_to :product
end
