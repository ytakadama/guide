class TourCancelNotifyMailer < ApplicationMailer
  def cancel_email(guide, tour)
    @guide = guide
    @tour = tour
    @body = ENV["TOUR_CANCEL_BODY"]
    @body3 = ENV["TOUR_CANCEL_BODY3"]

    mail(
      subject: "#{ENV['MAIL_TITLE']}#{ENV['TOUR_CANCEL_TITLE']}",
      to: guide.email
    )
  end
end
