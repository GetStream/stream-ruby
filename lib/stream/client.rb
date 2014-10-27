require 'stream/signer'
require 'stream/feed'

module Stream
    STREAM_URL_RE = /https\:\/\/(?<key>\w+)\:(?<secret>\w+).*site=(?<site>\d+)/i

    class Client
        attr_reader :api_key
        attr_reader :api_secret
        attr_reader :site

        def initialize(api_key='', api_secret='', site=0)
            
            if ENV['STREAM_URL'] =~ Stream::STREAM_URL_RE and (api_key.nil? || api_key.empty?)
                matches = Stream::STREAM_URL_RE.match(ENV['STREAM_URL'])
                api_key = matches['key']
                api_secret = matches['secret']
                site = matches['site']
            end

            if api_key.nil? || api_key.empty?
                raise ArgumentError, 'empty api_key parameter and missing or invalid STREAM_URL env variable'
            end

            @api_key = api_key
            @api_secret = api_secret
            @site = site
            @signer = Stream::Signer.new(api_secret)
        end

        def feed(feed_id)
            cleaned_feed_id = Stream::clean_feed_id(feed_id)
            signature = @signer.signature(cleaned_feed_id)
            Stream::Feed.new(self, feed_id, @api_key, signature)
        end

    end
end