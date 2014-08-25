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

        def signature(message)
            key = Digest::SHA1.digest @key.to_s
            signature = Base64.strict_encode64(OpenSSL::HMAC.digest(@sha1, key, message.to_s))
            self.urlSafeB64encode(signature)
        end
    end
end