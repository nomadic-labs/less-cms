class PublishWebsiteJob < ApplicationJob
  queue_as :default

  def perform(website, editor_info)
    service = DeployService.new(website, editor_info)
    service.deploy
  end
end