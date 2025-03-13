class RemindNotifyMailer < ApplicationMailer
  def creation_email(guide, tour)
    @guide = guide
    @tour = tour
    @body = ENV["REMIND_BODY"]
    @body3 = ENV["REMIND_BODY3"]

    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['REMIND_TITLE']}",
      to: guide.email
    )
  end
end
