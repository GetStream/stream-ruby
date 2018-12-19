require 'openssl'
require 'base64'

module Stream
  class Signer
    @key = nil

    def initialize(key)
      @key = key.to_s
    end

    def self.create_user_token(user_id, payload = {}, api_secret)
      payload['user_id'] = user_id
      return JWT.encode(payload, api_secret, 'HS256')
    end

    def self.create_jwt_token(resource, action, api_secret, feed_id = nil, user_id = nil)
      payload = {
          resource: resource,
          action: action
      }
      payload['feed_id'] = feed_id if feed_id
      payload['user_id'] = user_id if user_id

      JWT.encode(payload, api_secret, 'HS256')
    end
  end
end
