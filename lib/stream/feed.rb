require 'stream/signer'

module Stream
    class Feed
        attr_reader :id
        attr_reader :slug
        attr_reader :user_id
        attr_reader :token
        attr_reader :signature

        def initialize(client, feed_slug, user_id, token)
            if !self.valid_feed_slug feed_slug
                raise StreamInputData, "feed_slug can only contain alphanumeric characters"
            end

            if !self.valid_user_id user_id
                raise StreamInputData, "user_id can only contain alphanumeric characters plus underscores and dashes"
            end

            @id = "#{feed_slug}:#{user_id}"
            @client = client
            @user_id = user_id
            @slug = feed_slug
            @feed_url = "#{feed_slug}/#{user_id}"
            @token = token
            @signature = "#{feed_slug}#{user_id} #{token}"
        end

        def valid_feed_slug(feed_slug)
            !feed_slug[/^[^_\W]+$/].nil?
        end

        def valid_user_id(user_id)
            !user_id.to_s[/^[\w-]+$/].nil?
        end

        def get(params = {})
            uri = "/feed/#{@feed_url}/"
            if params[:mark_read] && params[:mark_read].is_a?(Array)
                params[:mark_read] = params[:mark_read].join(",")
            end
            if params[:mark_seen] && params[:mark_seen].is_a?(Array)
                params[:mark_seen] = params[:mark_seen].join(",")
            end
            @client.make_request(:get, uri, @signature, params)
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
            @client.make_request(:post, uri, @signature, {}, activity_data)
        end

        def add_activities(activities)
            uri = "/feed/#{@feed_url}/"
            activities.each do |activity|
                activity[:to] &&= self.sign_to_field(activity[:to])
            end
            data = {:activities => activities}
            @client.make_request(:post, uri, @signature, {}, data)
        end

        def remove(activity_id, foreign_id=false)
            self.remove_activity(activity_id, foreign_id)
        end

        def remove_activity(activity_id, foreign_id=false)
            uri = "/feed/#{@feed_url}/#{activity_id}/"
            params = {}
            params = {'foreign_id' => 1} if foreign_id
            @client.make_request(:delete, uri, @signature, params)
        end

        def delete
            uri = "/feed/#{@feed_url}/"
            @client.make_request(:delete, uri, @signature)
        end

        def follow(target_feed_slug, target_user_id)
            uri = "/feed/#{@feed_url}/follows/"
            follow_data = {
                :target => "#{target_feed_slug}:#{target_user_id}",
                :target_token => @client.feed(target_feed_slug, target_user_id).token
            }
            @client.make_request(:post, uri, @signature, {}, follow_data)
        end

        def followers(offset=0, limit=25)
            uri = "/feed/#{@feed_url}/followers/"
            params = {
                'offset' => offset,
                'limit' => limit
            }
            @client.make_request(:get, uri, @signature, params)
        end

        def following(offset=0, limit=25, filter=[])
            uri = "/feed/#{@feed_url}/follows/"
            params = {
                'offset' => offset,
                'limit' => limit,
                'filter' => filter.join(",")
            }
            @client.make_request(:get, uri, @signature, params)
        end

        def unfollow(target_feed_slug, target_user_id)
            uri = "/feed/#{@feed_url}/follows/#{target_feed_slug}:#{target_user_id}/"
            @client.make_request(:delete, uri, @signature)
        end
    end
end
