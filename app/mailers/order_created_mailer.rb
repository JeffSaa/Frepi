class OrderCreatedMailer < ApplicationMailer

  #ADMIN = ['ernestodelae@frepi.com.co', 'butron4@hotmail.com', 'amcamargo95@gmail.com', 'borref22@gmail.com', 'pablobutca@gmail.com']
  

  def notification_email(order, user)
    @order = order
    @user = user
    administrators = User.where(administrator: true).pluck(:email)
    mail to: administrators, subject: 'Orden Creada!'
  end


  def notification_client(order, user)
    @order = order
    @user = user
    mail to: user.email, subject: 'Gracias por tu compra'
  end
end
