require_relative "config/boot"
require_relative "config/environment"
require 'clockwork'
require 'sidekiq'

module Clockwork

  handler do |job|
    puts "Running #{job}"
  end

  every(1.hours, 'orders_worker.send_notification') do
    puts 'Event: Sending expired orders'
    OrdersWorker.send_notification
  end

  every(1.day, 'orders_worker.establish_best_customers', at: '02:00') do
    puts 'Event: Updating customers'
    OrdersWorker.establish_best_customers
  end
end