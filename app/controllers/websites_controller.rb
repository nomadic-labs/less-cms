class WebsitesController < ApplicationController
  before_action :restrict_access, only: :deploy
  skip_before_action :verify_authenticity_token, except: [:new, :create]

  def index
    @websites = Website.order(:created_at)
    render json: @websites
  end

  def show
    @website = Website.friendly.find(params[:id])
    render json: @website
  end

  def new
    @website = Website.new
  end

  def create
    @website = Website.new(website_params)
    if @website.save
      render json: @website, status: :created
    end
  end

  def update
    @website = Website.friendly.find params[:id]
    @website.update(website_params)

    render json: @website, status: :ok
  end

  def destroy
    @website = Website.friendly.find params[:id]
    @website.destroy
    render json: nil, status: :no_content
  end

  def deploy
    @website = Website.friendly.find params[:id]
    service = DeployService.new @website
    begin
      service.deploy
      render json: { message: "Deployed!", status: :ok }
    rescue DeploymentError => e
      render json: { error: e, status: :unprocessable_entity }
    end
  end

  def website_params
    params
      .require(:website)
      .permit(
        :project_name,
        :source_repo,
        :firebase_api_key,
        :firebase_auth_domain,
        :firebase_database_url,
        :firebase_project_id,
        :firebase_config)
  end
end
