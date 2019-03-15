class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Knock::Authenticable

  protected

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      @current_website = Website.exists?(access_token: token)
    end
  end
end
