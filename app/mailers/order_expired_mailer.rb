class OrderExpiredMailer < ApplicationMailer
  ADMIN = ['ernestodelae@frepi.com.co', 'butron4@hotmail.com', 'amcamargo95@gmail.com', 'borref22@gmail.com', 'pablobutca@gmail.com']
  
  # TODO: ADD information about products (ask about it to ernesto)
  def notification_email(orders)
    @expire_orders = orders
    @customers = []
    @expire_orders.each do |order|
      order = Order.find(order['id'])
      @customers.push(order.user)
      order.notification_email = true
      order.save
    end
    mail to: ADMIN, subject: 'Ordenes vencidas!'
  end
end
