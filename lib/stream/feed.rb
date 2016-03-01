require "stream/signer"
require 'jwt'

module Stream
  class Feed
    attr_reader :id
    attr_reader :slug
    attr_reader :user_id
    attr_reader :token

    def initialize(client, feed_slug, user_id, token)
      unless valid_feed_slug feed_slug
        raise StreamInputData, "feed_slug can only contain alphanumeric characters plus underscores"
      end

      unless valid_user_id user_id
        raise StreamInputData, "user_id can only contain alphanumeric characters plus underscores and dashes"
      end

      @id = "#{feed_slug}:#{user_id}"
      @client = client
      @user_id = user_id
      @slug = feed_slug
      @feed_name = "#{feed_slug}#{user_id}"
      @feed_url = "#{feed_slug}/#{user_id}"
      @token = token
    end

    def readonly_token
      create_jwt_token("*", "read")
    end

    def valid_feed_slug(feed_slug)
      !feed_slug[/^[a-zA-Z0-9_]+$/].nil?
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
      auth_token = create_jwt_token("feed", "read")

      @client.make_request(:get, uri, auth_token, params)
    end

    def sign_to_field(to)
      to.map do |feed_id|
        feed_slug, user_id = feed_id.split(":")
        feed = @client.feed(feed_slug, user_id)
        "#{feed.id} #{feed.token}"
      end
    end

    def add_activity(activity_data)
      uri = "/feed/#{@feed_url}/"
      activity_data[:to] &&= sign_to_field(activity_data[:to])
      auth_token = create_jwt_token("feed", "write")

      @client.make_request(:post, uri, auth_token, {}, activity_data)
    end

    def add_activities(activities)
      uri = "/feed/#{@feed_url}/"
      activities.each do |activity|
        activity[:to] &&= sign_to_field(activity[:to])
      end
      data = { :activities => activities }
      auth_token = create_jwt_token("feed", "write")

      @client.make_request(:post, uri, auth_token, {}, data)
    end

    def remove(activity_id, foreign_id = false)
      remove_activity(activity_id, foreign_id)
    end

    def remove_activity(activity_id, foreign_id = false)
      uri = "/feed/#{@feed_url}/#{activity_id}/"
      params = {}
      params = { "foreign_id" => 1 } if foreign_id
      auth_token = create_jwt_token("feed", "delete")

      @client.make_request(:delete, uri, auth_token, {}, params)
    end

    def delete
      uri = "/feed/#{@feed_url}/"
      auth_token = create_jwt_token("feed", "delete")

      @client.make_request(:delete, uri, auth_token)
    end

    def follow(target_feed_slug, target_user_id)
      uri = "/feed/#{@feed_url}/follows/"
      follow_data = {
        :target => "#{target_feed_slug}:#{target_user_id}",
        :target_token => @client.feed(target_feed_slug, target_user_id).token
      }
      auth_token = create_jwt_token("follower", "write")

      @client.make_request(:post, uri, auth_token, {}, follow_data)
    end

    def followers(offset = 0, limit = 25)
      uri = "/feed/#{@feed_url}/followers/"
      params = {
        "offset" => offset,
        "limit" => limit
      }
      auth_token = create_jwt_token("follower", "read")

      @client.make_request(:get, uri, auth_token, {}, params)
    end

    def following(offset = 0, limit = 25, filter = [])
      uri = "/feed/#{@feed_url}/follows/"
      params = {
        "offset" => offset,
        "limit" => limit,
        "filter" => filter.join(",")
      }
      auth_token = create_jwt_token("follower", "read")

      @client.make_request(:get, uri, auth_token, {}, params)
    end

    def unfollow(target_feed_slug, target_user_id)
      uri = "/feed/#{@feed_url}/follows/#{target_feed_slug}:#{target_user_id}/"
      auth_token = create_jwt_token("follower", "delete")

      @client.make_request(:delete, uri, auth_token, {auth_token: auth_token})
    end

    private

    def create_jwt_token(resource, action, feed_id=nil, user_id=nil)
      payload = {
        "resource" => resource,
        "action" => action,
        "feed_id" => @feed_name
      }
      payload["feed_id"] = feed_id if feed_id
      payload["user_id"] = user_id if user_id

      return JWT.encode(payload, @client.api_secret, 'HS256')
    end
  end
end
