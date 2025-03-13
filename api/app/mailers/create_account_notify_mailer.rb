class CreateAccountNotifyMailer < ApplicationMailer
  def creation_email(account, password)
    @account = account
    @password = password
    @body = ENV["ACCOUNT_BODY"]
    @body3 = ENV["ACCOUNT_BODY3"]

    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['ACCOUNT_TITLE']}",
      to: account.email
    )
  end
end
