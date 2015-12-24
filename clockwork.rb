require_relative "config/boot"
require_relative "config/environment"
require 'clockwork'
require 'sidekiq'

module Clockwork

  handler do |job|
    puts "Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end



  every(5.seconds, 'orders_worker.send_notification') do
    OrdersWorker.send_notification
  end

end