require 'stream/signer'
require 'jwt'

module Stream
  class Feed
    attr_reader :id
    attr_reader :slug
    attr_reader :user_id

    def initialize(client, feed_slug, user_id)
      unless valid_feed_slug feed_slug
        raise StreamInputData, 'feed_slug can only contain alphanumeric characters plus underscores'
      end

      unless valid_user_id user_id
        raise StreamInputData, 'user_id can only contain alphanumeric characters plus underscores and dashes'
      end

      @id = "#{feed_slug}:#{user_id}"
      @client = client
      @user_id = user_id
      @slug = feed_slug
      @feed_name = "#{feed_slug}#{user_id}"
      @feed_url = "#{feed_slug}/#{user_id}"
    end

    def readonly_token
      create_jwt_token('*', 'read')
    end

    def valid_feed_slug(feed_slug)
      !feed_slug[/^[a-zA-Z0-9_]+$/].nil?
    end

    def valid_user_id(user_id)
      !user_id.to_s[/^[\w-]+$/].nil?
    end

    def get(params = {})
      if params[:enrich] or params[:reactions]
        uri = "/enrich/feed/#{@feed_url}/"
      else
        uri = "/feed/#{@feed_url}/"
      end
      if params[:mark_read] && params[:mark_read].is_a?(Array)
        params[:mark_read] = params[:mark_read].join(',')
      end
      if params[:mark_seen] && params[:mark_seen].is_a?(Array)
        params[:mark_seen] = params[:mark_seen].join(',')
      end
      if params[:reactions].respond_to?(:keys)
        if params[:reactions][:own]
          params[:withOwnReactions] = true
        end
        if params[:reactions][:recent]
          params[:withRecentReactions] = true
        end
        if params[:reactions][:counts]
          params[:withReactionCounts] = true
        end
      end
      [:enrich, :reactions].each { |k| params.delete(k) }

      auth_token = create_jwt_token('feed', 'read')
      @client.make_request(:get, uri, auth_token, params)
    end

    def add_activity(activity_data)
      uri = "/feed/#{@feed_url}/"
      data = activity_data.clone
      auth_token = create_jwt_token('feed', 'write')

      @client.make_request(:post, uri, auth_token, {}, data)
    end

    def add_activities(activities)
      uri = "/feed/#{@feed_url}/"
      data = {:activities => activities}
      auth_token = create_jwt_token('feed', 'write')

      @client.make_request(:post, uri, auth_token, {}, data)
    end

    def remove(activity_id, foreign_id = false)
      remove_activity(activity_id, foreign_id)
    end

    def remove_activity(activity_id, foreign_id = false)
      uri = "/feed/#{@feed_url}/#{activity_id}/"
      params = {}
      params = {foreign_id: 1} if foreign_id
      auth_token = create_jwt_token('feed', 'delete')

      @client.make_request(:delete, uri, auth_token, params)
    end

    def update_activity(activity)
      update_activities([activity])
    end

    def update_activities(activities)
      auth_token = create_jwt_token('activities', '*', '*')

      @client.make_request(:post, '/activities/', auth_token, {}, 'activities' => activities)
    end

    def update_activity_to_targets(foreign_id, time, new_targets: nil, added_targets: nil, removed_targets: nil)
      uri = "/feed_targets/#{@feed_url}/activity_to_targets/"
      data = {
        'foreign_id': foreign_id,
        'time': time
      }

      if !new_targets.nil?
        data['new_targets'] = new_targets
      end
      if !added_targets.nil?
        data['added_targets'] = added_targets
      end
      if !removed_targets.nil?
        data['removed_targets'] = removed_targets
      end
      auth_token = create_jwt_token('feed_targets', 'write')

      @client.make_request(:post, uri, auth_token, {}, data)
    end

    def follow(target_feed_slug, target_user_id, activity_copy_limit = 300)
      uri = "/feed/#{@feed_url}/follows/"
      activity_copy_limit = 0 if activity_copy_limit < 0
      activity_copy_limit = 1000 if activity_copy_limit > 1000

      follow_data = {
          target: "#{target_feed_slug}:#{target_user_id}",
          activity_copy_limit: activity_copy_limit
      }
      auth_token = create_jwt_token('follower', 'write')

      @client.make_request(:post, uri, auth_token, {}, follow_data)
    end

    def followers(offset = 0, limit = 25)
      uri = "/feed/#{@feed_url}/followers/"
      params = {
          offset: offset,
          limit: limit
      }
      auth_token = create_jwt_token('follower', 'read')

      @client.make_request(:get, uri, auth_token, params)
    end

    def following(offset = 0, limit = 25, filter = [])
      uri = "/feed/#{@feed_url}/follows/"
      params = {
          offset: offset,
          limit: limit,
          filter: filter.join(',')
      }
      auth_token = create_jwt_token('follower', 'read')

      @client.make_request(:get, uri, auth_token, params)
    end

    def unfollow(target_feed_slug, target_user_id, keep_history = false)
      uri = "/feed/#{@feed_url}/follows/#{target_feed_slug}:#{target_user_id}/"
      auth_token = create_jwt_token('follower', 'delete')
      params = {}
      params['keep_history'] = true if keep_history
      @client.make_request(:delete, uri, auth_token, params)
    end

    private

    def create_jwt_token(resource, action, feed_id = nil, user_id = nil)
      feed_id = @feed_name if feed_id.nil?
      Stream::Signer.create_jwt_token(resource, action, @client.api_secret, feed_id, user_id)
    end
  end
end
