require "openssl"
require "base64"

module Stream
  class Signer
    @key = nil

    def initialize(key)
      @key = key.to_s
      @sha1 = OpenSSL::Digest.new("sha1")
    end

    def urlsafe_encodeb64(value)
      value.tr("+", "-").tr("/", "_").gsub(/^=+/, "").gsub(/=+$/, "")
    end

    def sign_message(message)
      key = Digest::SHA1.digest @key.to_s
      token = Base64.strict_encode64(OpenSSL::HMAC.digest(@sha1, key, message))
      urlsafe_encodeb64(token)
    end

    def sign(feed_slug, user_id)
      sign_message("#{feed_slug}#{user_id}")
    end

    def self.create_jwt_token(resource, action, api_secret, feed_id = nil, user_id = nil)
      payload = {
        "resource" => resource,
        "action" => action
      }
      payload["feed_id"] = feed_id if feed_id
      payload["user_id"] = user_id if user_id

      JWT.encode(payload, api_secret, "HS256")
    end
  end
end
