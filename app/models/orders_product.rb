class OrdersProduct < ActiveRecord::Base

  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :order, :product, presence: true
  validates :quantity, numericality: { only_integer: true }

  # Callbacks
  after_create :increment_counter

  # Methods
  private
  def increment_counter
    self.product.increment!(:sales_count, self.quantity)
  end
end

