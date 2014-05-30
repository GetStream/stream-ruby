require 'stream'

describe Stream::Client do

    it "feed returns a Feed instance" do
        client = Stream::Client.new('key', 'secret')
        feed = client.feed('feed:42')
        expect(feed).to be_instance_of Stream::Feed
        feed.feed_id.should eq 'feed:42'
    end

end