class DeleteAccountNotifyMailer < ApplicationMailer
  def delete_email(account)
    @account = account
    @body = ENV["ACCOUNT_DELETE_BODY"]

    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['ACCOUNT_DELETE_TITLE']}",
      to: account.email
    )
  end
end
