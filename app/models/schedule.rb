class Schedule < ActiveRecord::Base

  # Enumerators
  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  has_many :orders_schedules
  has_many :shoppers_schedules
  has_many :orders, through: :orders_schedules
  has_many :shoppers, through: :shoppers_schedules
end
