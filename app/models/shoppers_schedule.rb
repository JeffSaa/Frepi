class ShoppersSchedule < ActiveRecord::Base

  # Associations
  belongs_to :shopper
  belongs_to :schedule

  # Validations
  validates :shopper, :schedule, presence: true
end
