require 'spec_helper'
require 'stream'

describe Stream::Client do
  
    after do
        ENV.delete 'STREAM_URL'
    end

    it "feed returns a Feed instance with clean feed_id" do
        client = Stream::Client.new('key', 'secret')
        client.api_key.should eq 'key'
        client.api_secret.should eq 'secret'
        feed = client.feed('feed:42')
        expect(feed).to be_instance_of Stream::Feed
        feed.feed_id.should eq 'feed:42'
    end
    
    it "on heroku we connect using environment variables" do
        ENV['STREAM_URL'] = 'https://thierry:pass@getstream.io/?site=1'
        client = Stream::Client.new()
        client.api_key.should eq 'thierry'
        client.api_secret.should eq 'pass'
        client.site.should eq '1'
    end

    it "wrong heroku vars" do
        ENV['STREAM_URL'] = 'https://thierry:pass@getstream.io/?a=1'
        expect{Stream::Client.new()}.to raise_error(ArgumentError)
    end

    it "but overwriting environment variables should be possible" do
        ENV['STREAM_URL'] = 'https://thierry:pass@getstream.io/?site=1'
        client = Stream::Client.new('1','2','3')
        client.api_key.should eq '1'
        client.api_secret.should eq '2'
        client.site.should eq '3'
        ENV.delete 'STREAM_URL'
    end

end