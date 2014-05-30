require 'stream/client'
require 'stream/version'
require 'stream/signer'

module Stream
    class << self
        def connect(api_key, api_secret)
            Stream::Client.new(api_key, api_secret)
        end

        def clean_feed_id(feed_id)
            feed_id.sub(':', '')
        end
    end
end