class Schedule < ActiveRecord::Base

  # Enumerators
  DAY = %w(MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY SUNDAY)
  enum day: DAY

  # Associations
  has_many :orders_schedules
  has_many :shoppers_schedules
  has_many :orders, through: :orders_schedules
  has_many :shoppers, through: :shoppers_schedules

  # Validations
  validates          :start_hour, :end_hour, presence: true
  validates          :day, inclusion: { in: DAY }
  validates_datetime :end_hour, on_or_after: :start_hour
end
