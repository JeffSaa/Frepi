require "action_controller"
require "action_controller/serialization"
require "#{Rails.root}/app/serializers/product_serializer.rb"

class OrdersWorker
  include Sidekiq::Worker

  def perform(orders)
    orders = ActiveSupport::JSON.decode(orders)
    OrderExpiredMailer.notification_email(orders).deliver_now
    puts 'sending'
  end

  # Include User information!!
  def self.send_notification
    orders = Order.in_progress.expiries(DateTime.current)
    puts 'sending orders'
    perform_async(orders.to_json) unless orders.empty?
  end

  def self.establish_best_customers
    p 'userss'
    start_date = DateTime.now.beginning_of_month
    end_date = DateTime.now.end_of_month
    loyal_users = Order.created_between(start_date, end_date).group(:user).count.keep_if { |user, orders_counter|  orders_counter >= 2 }
    User.find_each(batch_size: 1000) do |user|
      user.loyal_costumer = loyal_users[user] ? true : false
      user.save
    end
  end
end