require 'httparty'
require 'stream/exceptions'
require 'stream/feed'
require 'stream/signer'


module Stream
    STREAM_URL_RE = /https\:\/\/(?<key>\w+)\:(?<secret>\w+)@((api\.)|((?<location>[-\w]+)\.))?getstream\.io\/?*.app_id=(?<app_id>\d+)/i

    class Client
        attr_reader :api_key
        attr_reader :api_secret
        attr_reader :app_id
        attr_reader :api_version
        attr_reader :location

        def initialize(api_key='', api_secret='', app_id=nil, opts={})

            if ENV['STREAM_URL'] =~ Stream::STREAM_URL_RE and (api_key.nil? || api_key.empty?)
                matches = Stream::STREAM_URL_RE.match(ENV['STREAM_URL'])
                api_key = matches['key']
                api_secret = matches['secret']
                app_id = matches['app_id']
                opts[:location] = matches['location']
            end

            if api_key.nil? || api_key.empty?
                raise ArgumentError, 'empty api_key parameter and missing or invalid STREAM_URL env variable'
            end

            @api_key = api_key
            @api_secret = api_secret
            @app_id = app_id
            @location = opts[:location]
            @api_version = opts.fetch(:api_version, 'v1.0')
            @signer = Stream::Signer.new(api_secret)
        end

        def feed(feed_slug, user_id)
            token = @signer.sign(feed_slug, user_id)
            Stream::Feed.new(self, feed_slug, user_id, token)
        end

        def get_default_params
            {:api_key => @api_key}
        end

        def get_http_client
            StreamHTTPClient.new(@api_version, @location)
        end

        def make_request(method, relative_url, signature, params=nil, data=nil)
            auth_headers = {'Authorization' => signature}
            params = params.nil? ? {} : params
            data = data.nil? ? {} : data
            default_params = self.get_default_params
            default_params.merge!(params)
            response = self.get_http_client.make_http_request(method, relative_url, default_params, data, auth_headers)
        end

    end

    class StreamHTTPClient

        include HTTParty
        default_timeout 3

        def initialize(api_version='v1.0', location=nil)
            if location.nil?
                location_name = "api"
            else
                location_name = "#{location}-api"
            end
            self.class.base_uri "https://#{location_name}.getstream.io/api/#{api_version}"
        end

        def make_http_request(method, relative_url, params=nil, data=nil, headers=nil)
            headers['Content-Type'] = 'application/json'
            headers['User-Agent'] = "stream-ruby-#{Stream::VERSION}"
            response = self.class.send(method, relative_url, :headers => headers, :query => params, :body => data.to_json )
            case response.code
              when 200..203
                return response
              when 204...600
                raise StreamApiResponseException, "#{response['exception']} details: #{response['detail']}"
            end
        end
    end

end
