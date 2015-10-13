class Schedule < ActiveRecord::Base

  # Enumerators
  enum day: %w(monday tuesday wednesday thursday friday saturday sunday)

  # Associations
  has_many :orders_schedules
  has_many :shoppers_schedules
  has_many :orders, through: :orders_schedules
  has_many :shoppers, through: :shoppers_schedules

  # Validations
  validates          :start_hour, :end_hour, presence: true
  validates          :day, inclusion: { in: %W(monday tuesday wednesday thursday friday saturday sunday) }
  validates_datetime :end_hour, on_or_after: :start_hour
end
