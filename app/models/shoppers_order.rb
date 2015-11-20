class ShoppersOrder < ActiveRecord::Base

  # Associations
  belongs_to :shopper
  belongs_to :order

  # Validations
  validates :shopper, :order, presence: true

  # Callbacks
  before_create :set_date

  # Methods
  def set_date
    self.accepted_date = DateTime.current
  end
end
