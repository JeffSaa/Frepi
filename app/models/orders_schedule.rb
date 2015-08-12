class OrdersSchedule < ActiveRecord::Base

  # Associations
  belongs_to :order
  belongs_to :schedule

  # Validations
  validates :order, :schedule, presence: true
end
