class ShoppersSchedule < ActiveRecord::Base
  belongs_to :shopper
  belongs_to :schedule
end
