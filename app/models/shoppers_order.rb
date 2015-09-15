class ShoppersOrder < ActiveRecord::Base

  # Associations
  belongs_to :shopper
  belongs_to :order

  # Validations
  validates :shopper, :order, presence: true
  validates_datetime :accepted_date
end
