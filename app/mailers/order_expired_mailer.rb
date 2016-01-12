class OrderExpiredMailer < ApplicationMailer
  ADMIN = 'amcamargo95@gmail.com'

  # TODO: ADD information about products (ask aboout it to ernesto)
  def notification_email(orders)
    @orders = orders
    @users = []
    p orders
    @orders.each do |order|
      order = Order.find(order['id'])
      @users.push(order.user)
      order.notification_email = true
      order.save
    end
    mail to: ADMIN, subject: 'Ordenes vencidas!'
  end
end
