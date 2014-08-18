class SupportersController < InheritedResources::Base
  actions :create, :show, :new

  def new
    @supporter = Supporter.new is_supporter: true
  end

  def show
    @supporter = Supporter.find_by_slug!(params[:path])
    render 'pages/index'
  end

  def create
    create! do |success, failure|
      success.html do
        if resource.is_custom
          redirect_to "/#{resource.slug}"
        else
          redirect_to root_url(anchor: "supporters")
        end
      end
      failure.html
    end
  end

  def permitted_params
    params.permit(supporter: [:name, :title, :url, :email, :is_custom, :hack, :phone, :is_supporter, :company, :slug])
  end
end
