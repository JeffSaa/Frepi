class OrdersProduct < ActiveRecord::Base

  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :order, :product, presence: true
  validates :quantity, numericality: { only_integer: true,  greater_than: 0 }
  validates :acquired, inclusion: { in: [true, false] }

  # Callbacks
  after_touch    :increment_counter
  after_destroy :decrement_counter

  # Methods
  def decrement_counter
    self.product.decrement!(:sales_count, self.quantity)
  end

  def increment_counter  
    self.product.increment!(:sales_count, self.quantity)
  end
end

