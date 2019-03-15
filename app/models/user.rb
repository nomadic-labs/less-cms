class User
  def self.from_token_payload payload
    p "JWT token payload"
    p payload
    payload["sub"]
  end
end