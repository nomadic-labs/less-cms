require 'open-uri'
require 'zip'

class Website < ApplicationRecord
  after_create :generate_access_token

  def download_source_repo
    content = open(source_repo)
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

  def build_website(website_root_dir)
    Dir.chdir(website_root_dir) do
      p "running yarn in #{website_root_dir}"
      yarn_result = %x(yarn)
      p yarn_result

      p "running yarn build"
      build_result = %x(yarn build)
      p build_result
    end
  end

  def write_firebase_config_file(website_root_dir)
    filepath = File.join(website_root_dir, 'config', 'firebase-config.json')
    File.open(filepath, "w+") do |f|
      f.write(firebase_config)
    end
  end

  def write_env_file(website_root_dir)
    filepath = File.join(website_root_dir, '.env.production')
    File.open(filepath, "w+") do |f|
      deploy_endpoint = Rails.application.routes.url_helpers.deploy_website_url(self, host: "localhost:3000", protocol: "http")
      f.write("GATSBY_DEPLOY_ENDPOINT=#{deploy_endpoint}")
    end
  end

  def deploy_to_firebase(website_root_dir)
    Dir.chdir(website_root_dir) do
      # need to set project
      p "deploying to firebase"
      deploy_result = %x(firebase deploy)
      p deploy_result
    end
  end

  def remove_project_files(website_root_dir)
    FileUtils.rm_rf(website_root_dir)
  end

  def validate_user_permissions(uid)

  end

  def deploy(uid)
    p "deploying website #{id} from #{source_repo}"
    validate_user_permissions(uid)
    website_root_dir = download_source_repo
    write_firebase_config_file(website_root_dir)
    write_env_file(website_root_dir)
    build_website(website_root_dir)
    # deploy_to_firebase(website_root_dir)
    remove_project_files(website_root_dir)
  end

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)

    self.save
  end
end
