class NotAssignMailer < ApplicationMailer
  def creation_email(guide, tour)
    @guide = guide
    @tour = tour
    @body = ENV["NOT_ASSIGN_BODY"]
    @body3 = ENV["NOT_ASSIGN_BODY3"]

    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['NOT_ASSIGN_TITLE']}",
      to: guide.email
    )
  end
end
