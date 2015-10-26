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
    # 
    # 
    # follows = [
    #   {:source => 'flat:1', :target => 'user:1'},
    #   {:source => 'flat:1', :target => 'user:3'}
    # ]
    # @client.follow_many(follows)
    # 
    def follow_many(follows)
      self.make_signed_request(:post, '/follow_many/', {}, follows)
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
      self.make_signed_request(:post, '/feed/add_to_many/', {}, data)
    end
    end
end
