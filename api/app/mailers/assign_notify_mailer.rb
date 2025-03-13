class AssignNotifyMailer < ApplicationMailer
  def creation_email(guide, tour)
    @guide = guide
    @tour = tour
    @body = ENV["ASSIGN_NOTIFY_BODY"]
    @body3 = ENV["ASSIGN_NOTIFY_BODY3"]

    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['ASSIGN_NOTIFY_TITLE']}",
      to: guide.email
    )
  end
end
