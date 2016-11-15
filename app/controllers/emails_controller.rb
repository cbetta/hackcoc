class EmailsController < ApplicationController
  def show
    redirect_to :root
  end

  def new
  end

  def create
    email_supporter
    redirect_to :root, notice: "We have sent an link to the email address you provided. This link is only valid for 30 minutes."
  end

  private

  def email_supporter
    supporter = Supporter.where(email: params[:supporter][:email]).order(:created_at).first
    if supporter
      supporter.generate_access_token
      SupporterMailer.edit_link(supporter).deliver_later
    end
  end
end
