require 'stream/signer'
require 'stream/feed'

module Stream
    class Client
        attr_reader :api_key
        attr_reader :api_secret
        attr_reader :site

        def initialize(api_key='', api_secret='', site=0)
            # Support the Heroku STREAM_URL environment variable
            
            if ENV['STREAM_URL'] != nil and api_key == ''
                matches = /https\:\/\/(?<key>\w+)\:(?<secret>\w+).*site=(?<site>\d+)/i.match(ENV['STREAM_URL'])
                api_key = matches['key']
                api_secret = matches['secret']
                site = matches['site']
            end
          
            @api_key = api_key
            @api_secret = api_secret
            @site = site
            @signer = Stream::Signer.new(api_secret)
        end

        def feed(feed_id)
            cleaned_feed_id = Stream::clean_feed_id(feed_id)
            signature = @signer.signature(cleaned_feed_id)
            Stream::Feed.new(feed_id, @api_key, signature)
        end

    end
end