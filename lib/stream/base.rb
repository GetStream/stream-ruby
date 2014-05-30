require 'stream/client'
require 'stream/version'
require 'stream/signer'

module Stream
    class << self
        def connect(api_key, api_secret)
            Stream::Client.new(api_key, api_secret)
        end
    end
end