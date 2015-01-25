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
      # client.follow_many([['flat:4', 'user:1'], ['flat:4', 'user:2']])
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
