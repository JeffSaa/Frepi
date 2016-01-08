require_relative "config/boot"
require_relative "config/environment"
require 'clockwork'
require 'sidekiq'

module Clockwork

  handler do |job|
    puts "Running #{job}"
  end

  every(30.seconds, 'orders_worker.send_notification') do
    OrdersWorker.send_notification
  end

  every(5.seconds, 'orders_worker.establish_best_customers') do
    OrdersWorker.establish_best_customers
  end
end