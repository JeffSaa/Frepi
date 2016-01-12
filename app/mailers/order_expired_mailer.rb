class OrderExpiredMailer < ApplicationMailer
  ADMIN = 'amcamargo95@gmail.com'

  # TODO: ADD information about products (ask about it to ernesto)
  def notification_email(orders)
    @expire_orders = orders
    @customers = []
    p orders
    @expire_orders.each do |order|
      order = Order.find(order['id'])
      @customers.push(order.user)
      order.notification_email = true
      order.save
    end
    mail to: ADMIN, subject: 'Ordenes vencidas!'
  end
end
