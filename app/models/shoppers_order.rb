class ShoppersOrder < ActiveRecord::Base

  # Associations
  belongs_to :shopper
  belongs_to :order

  # Validations
  validates :shopper, :order, presence: true
  validates :shopper_id, uniqueness: { scope: :order_id }

  # Callbacks
  before_create :set_date, :increase_taken_orders_count
  before_destroy :decrease_taken_orders_count

  # Methods
  def set_date
    self.accepted_date = DateTime.current
  end

  def increase_taken_orders_count
    self.shopper.increment!(:taken_orders_count)
  end

  def decrease_taken_orders_count
    self.shopper.decrement!(:taken_orders_count)
  end
end
