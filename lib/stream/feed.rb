require 'httparty'
require 'stream/signer'
require 'stream/exceptions'

module Stream

    class StreamHTTPClient

        include HTTParty
        base_uri 'https://getstream.io/api'

        def make_http_request(method, relative_url, params=nil, data=nil, headers=nil)
            headers['Content-Type'] = 'application/json'
            response = self.class.send(method, relative_url, :headers => headers, :query => params, :body => data.to_json )
            case response.code
              when 200..203
                return response
              when 204...600
                raise StreamApiResponseException, response
            end
        end

    end

    class Feed
        @@http_client = nil

        attr_reader :feed_id
        attr_reader :token

        def initialize(client, feed_id, api_key, signature)
            @client = client
            @feed_id = Stream::clean_feed_id(feed_id)
            @feed_url = feed_id.sub(':', '/')
            @api_key = api_key
            @token = signature
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
            response = self.get_http_client.make_http_request(method, relative_url, default_params, data, @auth_headers)
        end

        def get(params = {})
            uri = "/feed/#{@feed_url}/"
            self.make_request(:get, uri, params)
        end

        def sign_to_field(to)
            to.map do |feed|
                feed_id = Stream::clean_feed_id(feed)
                token = @client.feed(feed_id).token
                "#{feed} #{token}"
            end
        end

        def add_activity(activity_data)
            uri = "/feed/#{@feed_url}/"
            if !activity_data[:to].nil?
                activity_data[:to] = self.sign_to_field(activity_data[:to])
            end
            self.make_request(:post, uri, nil, activity_data)
        end

        def add_activities(activities)
            uri = "/feed/#{@feed_url}/"
            activities.each do |activity|
                if !activity[:to].nil?
                    activity[:to] = self.sign_to_field(activity[:to])
                end
            end
            data = {:activities => activities}
            self.make_request(:post, uri, nil, data)
        end

        def remove(activity_id, foreign_id=false)
            uri = "/feed/#{@feed_url}/#{activity_id}/"
            params = nil
            if foreign_id
                params = {'foreign_id' => 1}
            end
            self.make_request(:delete, uri, params)
        end

        def delete()
            uri = "/feed/#{@feed_url}/"
            self.make_request(:delete, uri)
        end

        def follow(target_feed_id)
            uri = "/feed/#{@feed_url}/follows/"
            follow_data = {
                :target => target_feed_id,
                :target_token => @client.feed(target_feed_id).token
            }
            self.make_request(:post, uri, nil, follow_data)
        end

        def followers(offset=0, limit=25)
            uri = "/feed/#{@feed_url}/followers/"
            params = {
                'offset' => offset,
                'limit' => limit
            }
            self.make_request(:get, uri, params)
        end

        def following(offset=0, limit=25, filter=[])
            uri = "/feed/#{@feed_url}/follows/"
            params = {
                'limit' => limit,
                'offset' => offset,
                'filter' => filter.join(",")
            }
            self.make_request(:get, uri, params)
        end

        def unfollow(target_feed_id)
            uri = "/feed/#{@feed_url}/follows/#{target_feed_id}/"
            self.make_request(:delete, uri)
        end

    end
end