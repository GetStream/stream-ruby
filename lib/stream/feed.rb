require 'stream/signer'

module Stream
    class Feed
        attr_reader :feed_id

        def initialize(feed_id)
            self.validate_feed_id(feed_id)
            @feed_id = feed_id
        end

        def validate_feed_id(feed_id)
        end

        def get(**params)
        end

        def add_activity(activity_data)
        end

        def remove(activity_id)
        end

        def follow(feed_id)
        end

        def unfollow(feed_id)
        end

    end
end