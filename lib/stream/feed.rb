require 'httparty'
require 'stream/signer'
require 'stream/exceptions'

module Stream

    class StreamHTTPClient

        include HTTParty
        base_uri 'https://getstream.io/api/v1.0'
        default_timeout 3

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

    class Feed
        @@http_client = nil

        attr_reader :id
        attr_reader :feed_slug
        attr_reader :user_id
        attr_reader :token
        attr_reader :signature

        def initialize(client, feed_slug, user_id, token)
            @id = "#{feed_slug}:#{user_id}"
            @client = client
            @user_id = user_id
            @feed_slug = feed_slug
            @feed_url = "#{feed_slug}/#{user_id}"
            @token = token
            @signature = "#{@feed_slug}#{user_id} #{token}"
            @auth_headers = {'Authorization' => @signature}
        end

        def get_http_client
            @@http_client ||= StreamHTTPClient.new
        end

        def get_default_params
            {:api_key => @client.api_key}
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
            if params[:mark_read] and params[:mark_read].kind_of?(Array)
                params[:mark_read] = params[:mark_read].join(",")
            end
            if params[:mark_seen] and params[:mark_seen].kind_of?(Array)
                params[:mark_seen] = params[:mark_seen].join(",")
            end
            self.make_request(:get, uri, params)
        end

        def sign_to_field(to)
            to.map do |feed_id|
                feed_slug, user_id = feed_id.split(':')
                feed = @client.feed(feed_slug, user_id)
                "#{feed.id} #{feed.token}"
            end
        end

        def add_activity(activity_data)
            uri = "/feed/#{@feed_url}/"
            activity_data[:to] &&= self.sign_to_field(activity_data[:to])
            self.make_request(:post, uri, nil, activity_data)
        end

        def add_activities(activities)
            uri = "/feed/#{@feed_url}/"
            activities.each do |activity|
                activity[:to] &&= self.sign_to_field(activity[:to])
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

        def follow(feed_slug, user_id)
            uri = "/feed/#{@feed_url}/follows/"
            follow_data = {
                :target => "#{feed_slug}:#{user_id}",
                :target_token => @client.feed(feed_slug, user_id).token
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

        def unfollow(feed_slug, user_id)
            uri = "/feed/#{@feed_url}/follows/#{feed_slug}:#{user_id}/"
            self.make_request(:delete, uri)
        end

    end
end