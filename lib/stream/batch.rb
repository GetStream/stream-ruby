module Stream
  module Batch
    #
    # Follows many feeds in one single request
    #
    # @param [Array<Hash<:source, :target>>] follows the list of follows
    #
    # @return [nil]
    #
    # @example
    #   follows = [
    #     {:source => 'flat:1', :target => 'user:1'},
    #     {:source => 'flat:1', :target => 'user:3'}
    #   ]
    #   @client.follow_many(follows)
    #
    def follow_many(follows, activity_copy_limit = nil)
      query_params = {}
      unless activity_copy_limit.nil?
        query_params['activity_copy_limit'] = activity_copy_limit
      end
      signature = Stream::Signer.create_jwt_token('follower', '*', @api_secret, '*')
      make_request(:post, '/follow_many/', signature, query_params, follows)
    end

    #
    # Unfollow many feeds in one single request
    #
    # @param [Array<Hash<:source, :target, :keep_history>>] unfollows the list of follows to remove.
    #
    # return [nil]
    #
    # @example
    #   unfollows = [
    #     {source: 'user:1', target: 'timeline:1'},
    #     {source: 'user:2', target: 'timeline:2', keep_history: false}
    #   ]
    #   @client.unfollow_many(unfollows)
    #
    def unfollow_many(unfollows)
      signature = Stream::Signer.create_jwt_token('follower', '*', @api_secret, '*')
      make_request(:post, '/unfollow_many/', signature, {}, unfollows)
    end

    #
    # Adds an activity to many feeds in one single request
    #
    # @param [Hash] activity_data the activity do add
    # @param [Array<string>] feeds list of feeds (eg. 'user:1', 'flat:2')
    #
    # @return [nil]
    #
    def add_to_many(activity_data, feeds)
      data = {
        :feeds => feeds,
        :activity => activity_data
      }
      signature = Stream::Signer.create_jwt_token('feed', '*', @api_secret, '*')
      make_request(:post, '/feed/add_to_many/', signature, {}, data)
    end
  end
end
