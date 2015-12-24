class OrdersWorker
  p 'sadsadas' * 23
  include Sidekiq::Worker

  def perform
    #OrderExpiredMailer.notification_email(Order.first).deliver_now
    p 'sending' * 100
  end
end