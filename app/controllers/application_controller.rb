class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods

  protected

  def restrict_access
    website = Website.friendly.find(params[:id])
    authenticate_or_request_with_http_token do |token, options|
      firebase = FirebaseService.new(JSON.parse(website.firebase_config))
      validated_user = firebase.validate_token(token)
      @current_user = validated_user
      firebase.user_is_editor? validated_user
    end
  end
end
