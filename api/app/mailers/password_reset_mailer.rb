class PasswordResetMailer < ApplicationMailer
  def creation_email(admin, url)
    @admin = admin
    @url = url
    @body = ENV["PASSWORD_RESET_BODY"]

    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['PASSWORD_RESET_TITLE']}",
      to: admin.email
    )
  end
end
