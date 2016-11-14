class SupportersController < ApplicationController
  def new
    @supporter = Supporter.new is_supporter: true
  end

  def show
    @supporter = Supporter.find_by_slug!(params[:path])
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
    end
  end

  def permitted_params
    params.require(:supporter).permit(:name, :title, :url, :email, :is_custom, :hack, :phone, :is_supporter, :company, :slug)
  end
end
