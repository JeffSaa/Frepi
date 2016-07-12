class OrderCreatedMailer < ApplicationMailer

  #ADMIN = ['ernestodelae@frepi.com.co', 'butron4@hotmail.com', 'amcamargo95@gmail.com', 'borref22@gmail.com', 'pablobutca@gmail.com']
  ADMIN = ['amcamargo95@gmail.com']

  def notification_email(order, user)
    @order = order
    @user = user
    mail to: ADMIN, subject: 'Orden Creada!'
  end


  def notification_client(order, user)
    @order = order
    @user = user
    mail to: user.email, subject: 'Gracias por tu compra'

  end
end
