require "google/cloud/firestore"

class FirebaseService
  FIREBASE_AUTH_ENDPOINT = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo"

  def initialize(config)
    @config = config
  end

  def validate_token(token)
    url = "#{FIREBASE_AUTH_ENDPOINT}?key=#{@config['apiKey']}"
    firebase_verification_call = HTTParty.post(url, headers: { 'Content-Type' => 'application/json' }, body: { 'idToken' => token }.to_json )
    if firebase_verification_call.response.code == "200"
      firebase_infos = firebase_verification_call.parsed_response
      firebase_infos["users"][0]
    else
      Rails.logger.info "Firebase verification failed: #{firebase_verification_call.response}"
      raise StandardError, "Firebase verification failed: #{firebase_verification_call.response}"
    end
  end

  def user_is_editor?(user)
    return false if !user

    if @config["databaseURL"] # use firebase realtime database
      client = Firebase::Client.new(@config["databaseURL"], JSON.generate(@config["serviceAccountKey"]))
      response = client.get("users/#{user["localId"]}")
      response.success? && response.body["isEditor"] == true
    else # use firestore
      p "creating firestore client"
      client = Google::Cloud::Firestore.new(
        project_id: @config["projectId"],
        credentials: @config["serviceAccountKey"]
      )
      user_snap = client.doc("users/#{user["localId"]}").get
      user_snap[:isEditor] == true
    end
  end
end