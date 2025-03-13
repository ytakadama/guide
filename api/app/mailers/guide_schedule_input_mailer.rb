class GuideScheduleInputMailer < ApplicationMailer
  def creation_email(guide, url, tour)
    @guide = guide
    @url = url
    @tour = tour
    @body = ENV["GUIDE_SCHEDULE_BODY"]
    @body2 = ENV["GUIDE_SCHEDULE_BODY2"]
    @body3 = ENV["GUIDE_SCHEDULE_BODY3"]
    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['GUIDE_SCHEDULE_TITLE']}",
      to: guide.email
    )
  end
end
