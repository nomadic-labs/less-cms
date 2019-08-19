require 'open-uri'
require 'zip'

class DeploymentError < StandardError
  def initialize(msg="There was an error deploying the website.")
    super
  end
end

class DeployService

  def initialize(website, editor_info)
    @website = website
    @editor_info = editor_info
    @timestamp = Time.now
  end

  def deploy
    p "Deploy started for #{@website.project_name} by #{@editor_info['displayName']} at #{@timestamp}"
    Rails.logger.info "Deploy started for #{@website.project_name} by #{@editor_info['displayName']} at #{@timestamp}"
    Delayed::Worker.logger.info "Deploy started for #{@website.project_name} by #{@editor_info['displayName']} at #{@timestamp}"
    begin
      download_source_repo
      write_firebase_config_file
      write_env_file
      install_website_dependencies
      build_website
      deploy_to_firebase
      purge_cloudflare_cache
      remove_project_files
      notify_editor_success
    rescue StandardError => e
      remove_project_files
      notify_editor_failure
      raise StandardError, "An error occurred while deploying the website: #{e}"
    end
  end

  private

  def download_source_repo
    p "Dowloading source code from #{@website.source_repo}"
    Rails.logger.info "Dowloading source code from #{@website.source_repo}"
    Delayed::Worker.logger.info "Dowloading source code from #{@website.source_repo}"
    content = open(@website.source_repo)
    dest_dir = File.path("#{Rails.root}/tmp/website_root/")

    if File.directory?(dest_dir)
      FileUtils.rm_rf(dest_dir)
    end

    FileUtils.mkdir(dest_dir)

    entry_name = ""
    Zip::File.open_buffer(content) do |zip_file|
      zip_file.each do |entry|
        entry_name = entry.name
        fpath = File.join(dest_dir, entry.name)
        entry.extract(fpath)
      end
    end

    dir_name = entry_name.split("/")[0]
    p "Extracted files to #{dir_name}"
    Rails.logger.info "Extracted files to #{dir_name}"
    Delayed::Worker.logger.info "Extracted files to #{dir_name}"
    @website_root_dir = File.path("#{Rails.root}/tmp/website_root/#{dir_name}/")
  end

  def install_website_dependencies
    Dir.chdir(@website_root_dir) do
      p "Installing dependencies in #{@website_root_dir}"
      Rails.logger.info "Installing dependencies in #{@website_root_dir}"
      Delayed::Worker.logger.info "Installing dependencies in #{@website_root_dir}"
      yarn_result = system("yarn")
    end
  end

  def build_website
    Dir.chdir(@website_root_dir) do
      p "Building website"
      Rails.logger.info "Building website"
      Delayed::Worker.logger.info "Building website"
      result = system("yarn build")
    end
  end

  def write_firebase_config_file
    p "Writing firebase config file"
    Rails.logger.info "Writing firebase config file"
    Delayed::Worker.logger.info "Writing firebase config file"
    filepath = File.join(@website_root_dir, 'config', 'firebase-config.json')
    File.open(filepath, "w+") do |f|
      f.write(@website.firebase_config)
    end
  end

  def write_env_file
    filepath = File.join(@website_root_dir, '.env.production')
    host = "localhost"
    protocol ="http"

    if ENV["RAILS_ENV"] == "production"
      host = "www.lesscms.ca"
      protocol ="https"
    end

    File.open(filepath, "a+") do |f|
      deploy_endpoint = Rails.application.routes.url_helpers.deploy_website_url(@website, host: host, protocol: protocol)
      p "Writing deploy endpoint environment variable to file: #{deploy_endpoint}"
      Rails.logger.info "Writing deploy endpoint environment variable to file: #{deploy_endpoint}"
      Delayed::Worker.logger.info "Writing deploy endpoint environment variable to file: #{deploy_endpoint}"
      f.write("GATSBY_DEPLOY_ENDPOINT=#{deploy_endpoint}\n")

      p "Writing additional environment variables to file"
      Rails.logger.info "Writing additional environment variables to file"
      Delayed::Worker.logger.info "Writing additional environment variables to file"
      f.write(@website.environment_variables)
    end
  end

  def deploy_to_firebase
    Dir.chdir(@website_root_dir) do
      p "Deploying to firebase hosting"
      Rails.logger.info "Deploying to firebase hosting"
      Delayed::Worker.logger.info "Deploying to firebase hosting"
      deploy_result = %x(firebase use #{@website.firebase_project_id} && firebase deploy)
      Rails.logger.info "Build completed => #{deploy_result}"
      Delayed::Worker.logger.info "Build completed => #{deploy_result}"
    end
  end

  def purge_cloudflare_cache
    client = CloudflareService.new(@website)
    client.purge_cache
  end

  def remove_project_files
    p "Removing project root folder"
    Rails.logger.info "Removing project root folder"
    Delayed::Worker.logger.info "Removing project root folder"
    FileUtils.rm_rf(@website_root_dir) if File.directory?(@website_root_dir)
  end

  def notify_editor_success
    p "Sending success notification to: #{@editor_info['displayName']} at #{@editor_info['email']}"
    Rails.logger.info "Sending success notification to: #{@editor_info['displayName']} at #{@editor_info['email']}"
    Delayed::Worker.logger.info "Sending success notification to: #{@editor_info['displayName']} at #{@editor_info['email']}"

    EditorMailer.with(website: @website, editor_info: @editor_info).website_published_email.deliver_now
  end

  def notify_editor_failure
    p "Sending failure notification to: #{@editor_info['displayName']} at #{@editor_info['email']}"
    Rails.logger.info "Sending failure notification to: #{@editor_info['displayName']} at #{@editor_info['email']}"
    Delayed::Worker.logger.info "Sending failure notification to: #{@editor_info['displayName']} at #{@editor_info['email']}"

    EditorMailer.with(website: @website, editor_info: @editor_info).deploy_failed_email.deliver_now
  end
end