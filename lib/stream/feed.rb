require 'httparty'
require 'stream/signer'


module Stream

    class StreamHTTPClient

        include HTTParty
        base_uri 'https://getstream.io/api'

        def make_http_request(method, relative_url, params=nil, data=nil, headers=nil)
            response = self.class.send(method, relative_url, headers: headers, query: params, body: data)
        end

    end

    class Feed
        @@http_client = nil

        attr_reader :feed_id

        def initialize(feed_id, api_key, signature)
            @feed_id = Stream::clean_feed_id(feed_id)
            @feed_url = feed_id.sub(':', '/')
            @api_key = api_key
            @auth_headers = {'Authorization' => "#{@feed_id} #{signature}"}
        end

        def get_http_client
            if @@http_client.nil?
                @@http_client = StreamHTTPClient.new
            end
            @@http_client
        end

        def get_default_params
            {:api_key => @api_key}
        end

        def make_request(method, relative_url, params=nil, data=nil)
            params = params.nil? ? {} : params
            data = data.nil? ? {} : data
            default_params = self.get_default_params
            default_params.merge!(params)
            self.get_http_client.make_http_request(method, relative_url, default_params, data, @auth_headers)
        end

        def get(params = {})
            uri = "/feed/#{@feed_url}/"
            self.make_request(:get, uri, params)
        end

        def add_activity(activity_data)
            uri = "/feed/#{@feed_url}/"
            self.make_request(:post, uri, nil, activity_data)
        end

        def remove(activity_id)
            uri = "/feed/#{@feed_url}/#{activity_id}/"
            self.make_request(:delete, uri)
        end

        def follow(target_feed_id)
            uri = "/feed/#{@feed_url}/follows/"
            follow_data = {:target => target_feed_id}
            self.make_request(:post, uri, nil, follow_data)
        end

        def unfollow(target_feed_id)
            uri = "/feed/#{@feed_url}/follows/#{target_feed_id}/"
            self.make_request(:delete, uri)
        end

    end
end