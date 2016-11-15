class SupporterMailer < ApplicationMailer
  default from: 'no-reply@hackcodeofconduct.org'

  def edit_link supporter
    @supporter = supporter
    mail(to: supporter.email, subject: 'Hack Code of Conduct > Edit')
  end
end
