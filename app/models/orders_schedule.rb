class OrdersSchedule < ActiveRecord::Base

  # Associations
  belongs_to :order
  belongs_to :schedule
end
