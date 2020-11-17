require 'securerandom'

module Utils
  def generate_uniq_feed_name
    SecureRandom.uuid
  end
end
