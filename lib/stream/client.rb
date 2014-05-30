require 'stream/signer'
require 'stream/feed'

module Stream
    class Client

        def initialize(api_key, api_secret)
            @api_key = api_key
            @api_secret = api_secret
            @signer = Stream::Signer.new(api_secret)
        end

        def feed(feed_id)
            cleaned_feed_id = Stream::clean_feed_id(feed_id)
            signature = @signer.signature(cleaned_feed_id)
            Stream::Feed.new(feed_id, @api_key, signature)
        end

    end
end