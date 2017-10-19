require 'json'
require 'stream/client'
require 'stream/errors'
require 'stream/version'
require 'stream/signer'

module Stream
  class << self
    def connect(api_key, api_secret)
      Stream::Client.new(api_key, api_secret)
    end

    def get_feed_slug_and_id(feed_id)
      feed_id.sub(':', '')
    end
  end
end
