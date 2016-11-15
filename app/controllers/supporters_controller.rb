class SupportersController < ApplicationController

  def index
    redirect_to :supporters
  end

  def new
    @supporter = Supporter.new(
      is_supporter: true,
      is_custom: params['is_custom']
    )
  end

  def edit
    @supporter = Supporter.where(access_token: params[:id]).first

    if @supporter && @supporter.access_token_created_on > 30.minutes.ago
      @url = supporter_path(id: @supporter.access_token)
    else
      redirect_to :root, notice: "This link has expired. Please request a new link to update your profile."
    end
  end

  def update
    @supporter = Supporter.where(access_token: params[:id]).first

    if @supporter.update_attributes(permitted_params)
      if @supporter.is_custom
        redirect_to "/#{@supporter.slug}", notice: 'Profile updated'
      else
        redirect_to root_url, notice: 'Profile updated'
      end
    else
      render :edit
    end
  end

  def show
    @supporter = Supporter.custom.find_by_slug!(params[:path])
    render 'pages/index'
  end

  def create
    @supporter = Supporter.new(permitted_params)
    if @supporter.save
      if @supporter.is_custom
        redirect_to "/#{@supporter.slug}"
      else
        redirect_to root_url(anchor: "supporters")
      end
    else
      render :new
    end
  end

  def permitted_params
    params.require(:supporter).permit(:name, :title, :url, :email, :is_custom, :hack, :phone, :is_supporter, :company, :slug)
  end
end
