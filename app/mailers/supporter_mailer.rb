class SupporterMailer < ApplicationMailer
  default from: 'no-reply@hackcodeofconduct.org'

  def edit_link supporter
    @supporter = supporter
    mail(to: supporter.email, subject: 'Hack Code of Conduct > Edit')
  end

  def redesign_update
    emails = Supporter.pluck(:email).uniq
    mail(to: 'cristiano@betta.io', bcc: emails, subject: 'Hack Code of Conduct > New Design + Features')
  end
end
