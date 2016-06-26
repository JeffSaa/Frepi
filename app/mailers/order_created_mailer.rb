class OrderCreatedMailer < ApplicationMailer

  ADMIN = ['ernestodelae@frepi.com.co', 'butron4@hotmail.com', 'amcamargo95@gmail.com', 'borref22@gmail.com', 'pablobutca@gmail.com']

  def notification_email(order, user)
    @order = order
    @user = user
    mail to: ADMIN, subject: 'Orden Creada!'
  end
end
