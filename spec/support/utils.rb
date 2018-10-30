require 'securerandom'


module Utils
  def generate_uniq_feed_name()
    return SecureRandom.uuid
  end
end
