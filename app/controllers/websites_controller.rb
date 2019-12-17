class WebsitesController < ApplicationController
  before_action :restrict_access, only: :deploy
  skip_before_action :verify_authenticity_token, only: [:deploy]

  http_basic_authenticate_with name: ENV["app_name"], password: ENV["app_password"], except: :deploy

  def index
    @websites = Website.order(:created_at)
  end

  def show
    @website = Website.friendly.find(params[:id])
    render json: @website
  end

  def new
    @website = Website.new
    @submit_action = "create"
  end

  def create
    @website = Website.new(website_params)
    if @website.save
      render json: @website, status: :created
    end
  end

  def edit
    @website = Website.friendly.find(params[:id])
    @submit_action = "update"
    render :new
  end

  def update
    @website = Website.friendly.find params[:id]
    @website.update(website_params)

    render json: @website, status: :ok
  end

  def destroy
    @website = Website.friendly.find params[:id]
    @website.destroy
    redirect_to websites_url
  end

  def deploy
    @website = Website.friendly.find params[:id]
    PublishWebsiteJob.perform_later(@website, @current_user)
    begin
      render json: { message: "The website is being published. You will be notified by email when your changes are live.", status: :ok }
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
        :firebase_project_id,
        :cloudflare_zone_id,
        :firebase_config,
        :firebase_config_staging,
        :environment_variables)
  end
end
