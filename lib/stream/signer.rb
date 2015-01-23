require 'openssl'
require 'base64'

module Stream
    class Signer
        @key = nil

        def initialize(key)
            @key = key.to_s
            @sha1 = OpenSSL::Digest.new('sha1')
        end

        def urlSafeB64encode(value)
            value.gsub('+', '-').gsub('/', '_').gsub(/^=+/, '').gsub(/=+$/, '')
        end

        def sign_message(message)
            key = Digest::SHA1.digest @key.to_s
            token = Base64.strict_encode64(OpenSSL::HMAC.digest(@sha1, key, message))
            self.urlSafeB64encode(token)
        end

        def sign(feed_slug, user_id)
            self.sign_message("#{feed_slug}#{user_id}")
        end

    end
end