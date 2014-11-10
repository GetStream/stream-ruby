require 'stream/signer'
require 'stream/feed'

module Stream
    STREAM_URL_RE = /https\:\/\/(?<key>\w+)\:(?<secret>\w+).*app_id=(?<app_id>\d+)/i

    class Client
        attr_reader :api_key
        attr_reader :api_secret
        attr_reader :app_id
        attr_reader :api_version

        def initialize(api_key='', api_secret='', app_id=nil)
            if ENV['STREAM_URL'] =~ Stream::STREAM_URL_RE and (api_key.nil? || api_key.empty?)
                matches = Stream::STREAM_URL_RE.match(ENV['STREAM_URL'])
                api_key = matches['key']
                api_secret = matches['secret']
                app_id = matches['app_id']
            end

            if api_key.nil? || api_key.empty?
                raise ArgumentError, 'empty api_key parameter and missing or invalid STREAM_URL env variable'
            end

            @api_key = api_key
            @api_secret = api_secret
            @app_id = app_id
            @signer = Stream::Signer.new(api_secret)
        end

        def feed(feed_slug, user_id)
            token = @signer.sign(feed_slug, user_id)
            Stream::Feed.new(self, feed_slug, user_id, token)
        end

    end
end
