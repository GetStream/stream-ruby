require 'stream/signer'
require 'stream/feed'

module Stream
    class Client

        def initialize(api_key, api_secret)
            @api_key = api_key
            @api_secret = api_secret
        end

        def feed(feed_id)
            Stream::Feed.new(feed_id)
        end

    end
end