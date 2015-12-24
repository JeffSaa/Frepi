class OrderExpiredMailer < ApplicationMailer
  ADMIN = 'amcamargo95@gmail.com'

  def notification_email(order)
    @user = order.user
    @order = order
    mail to: ADMIN, subject: 'Order expired!'
  end
end
