require 'spec_helper'
require 'stream'

describe Stream::Client do
  
    after do
        ENV.delete 'STREAM_URL'
    end

    it "feed returns a Feed instance with id" do
        client = Stream::Client.new('key', 'secret')
        client.api_key.should eq 'key'
        client.api_secret.should eq 'secret'
        feed = client.feed('feed', '42')
        expect(feed).to be_instance_of Stream::Feed
        feed.user_id.should eq '42'
        feed.slug.should eq 'feed'
        feed.id.should eq 'feed:42'
    end
    
    it "on heroku we connect using environment variables" do
        ENV['STREAM_URL'] = 'https://thierry:pass@getstream.io/?app_id=1'
        client = Stream::Client.new()
        client.api_key.should eq 'thierry'
        client.api_secret.should eq 'pass'
        client.app_id.should eq '1'
    end

    it "wrong heroku vars" do
        ENV['STREAM_URL'] = 'https://thierry:pass@getstream.io/?a=1'
        expect{Stream::Client.new()}.to raise_error(ArgumentError)
    end

    it "but overwriting environment variables should be possible" do
        ENV['STREAM_URL'] = 'https://thierry:pass@getstream.io/?app_id=1'
        client = Stream::Client.new('1','2','3')
        client.api_key.should eq '1'
        client.api_secret.should eq '2'
        client.app_id.should eq '3'
        ENV.delete 'STREAM_URL'
    end

    it "should handle default location as api.getstream.io" do
        client = Stream::Client.new('1','2')
        http_client = client.get_http_client
        http_client.class.base_uri.should eq 'https://api.getstream.io/api/v1.0'
    end

    it "should handle us-east location as api.getstream.io" do
        client = Stream::Client.new('1','2', nil, :location => 'us-east')
        http_client = client.get_http_client
        http_client.class.base_uri.should eq 'https://us-east-api.getstream.io/api/v1.0'
    end

end