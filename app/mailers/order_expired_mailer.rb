class OrderExpiredMailer < ApplicationMailer
  ADMIN = 'amcamargo95@gmail.com'

  def notification_email(orders)
    p orders
    @orders = orders
    mail to: ADMIN, subject: 'Ordenes vencidas!'
  end
end
