require 'open-uri'
require 'zip'

class DeploymentError < StandardError
  def initialize(msg="There was an error deploying the website.")
    super
  end
end

class DeployService

  def initialize(website)
    @website = website
  end

  def deploy
    p "Deploying website #{@website.project_name} from #{@website.source_repo}"
    begin
      @website_root_dir = download_source_repo
      write_firebase_config_file
      write_env_file
      build_website
      deploy_to_firebase
      purge_cloudflare_cache
      remove_project_files
    rescue StandardError => e
      remove_project_files
      raise StandardError, "An error occurred while deploying the website: #{e}"
    end
  end

  private

  def download_source_repo
    p "Dowloading source code from #{@website.source_repo}"
    content = open(@website.source_repo)
    dest_dir = File.path("#{Rails.root}/tmp/website_root/")
    FileUtils.mkdir(dest_dir) unless File.directory?(dest_dir)

    entry_name = ""
    Zip::File.open_buffer(content) do |zip_file|
      zip_file.each do |entry|
        entry_name = entry.name
        fpath = File.join(dest_dir, entry.name)
        entry.extract(fpath)
      end
    end

    dir_name = entry_name.split("/")[0]
    File.path("#{Rails.root}/tmp/website_root/#{dir_name}/")
  end

  def build_website
    Dir.chdir(@website_root_dir) do
      p "Installing dependencies in #{@website_root_dir}"
      yarn_result = %x(yarn)

      p "Building website"
      build_result = %x(yarn build)
      p build_result
    end
  end

  def write_firebase_config_file
    p "Writing firebase config file"
    filepath = File.join(@website_root_dir, 'config', 'firebase-config.json')
    File.open(filepath, "w+") do |f|
      f.write(@website.firebase_config)
    end
  end

  def write_env_file
    filepath = File.join(@website_root_dir, '.env.production')
    File.open(filepath, "w+") do |f|
      deploy_endpoint = Rails.application.routes.url_helpers.deploy_website_url(@website, host: "localhost:3000", protocol: "http")
      p "Writing deploy endpoint environment variable to file: #{deploy_endpoint}"
      f.write("GATSBY_DEPLOY_ENDPOINT=#{deploy_endpoint}")
    end
  end

  def deploy_to_firebase
    Dir.chdir(@website_root_dir) do
      p "Deploying to firebase hosting"
      deploy_result = %x(firebase use #{@website.firebase_project_id} && firebase deploy)
    end
  end

  def purge_cloudflare_cache
    client = CloudflareService.new(@website)
    client.purge_cache
  end

  def remove_project_files
    p "Removing project root folder"
    FileUtils.rm_rf(@website_root_dir)
  end
end