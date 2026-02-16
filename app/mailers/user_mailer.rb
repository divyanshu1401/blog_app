class UserMailer < ApplicationMailer
  # You can change the 'from' address here or in application_mailer.rb
  default from: 'divyanshu.sharma1401@gmail.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://localhost:3000/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Blog!')
  end
end