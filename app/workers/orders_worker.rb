class OrdersWorker
  include Sidekiq::Worker

  def perform
    #OrderExpiredMailer.notification_email(Order.first).deliver_now
    puts 'sending'
  end


  def self.send_notification
    Orders.where(active: true, status: 0)
    perform_async
  end
end