class CloudflareService

  CLOUDFLARE_API_ENDPOINT = "https://api.cloudflare.com/client/v4"

  def initialize(website)
    @website = website
  end

  def purge_cache
    return nil unless @website.cloudflare_zone_id && @website.cloudflare_zone_id != ""

    p "Purging cache on Cloudflare"
    Rails.logger.info "Purging cache on Cloudflare"
    Delayed::Worker.logger.info "Purging cache on Cloudflare"

    url = "#{CLOUDFLARE_API_ENDPOINT}/zones/#{@website.cloudflare_zone_id}/purge_cache"
    headers = {
      'Content-Type' => 'application/json',
      'X-Auth-Key' => ENV["cloudflare_api_key"],
      'X-Auth-Email' => ENV["cloudflare_email"],
    }
    data = { "purge_everything" => true }.to_json
    response = HTTParty.post(url, headers: headers, body: data)

    if !response.parsed_response["success"]
      raise StandardError, "Unable to purge Cloudflare cache: #{response.parsed_response['errors']}"
    end
  end
end