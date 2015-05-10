require 'spec_helper'
require 'stream'

describe Stream::Feed do

    it "should validate feed_id" do
      feed = Stream::Feed.new(nil, 'slug', 'user_id', '')
    end

    it "should validate user_id" do
      feed = Stream::Feed.new(nil, 'slug', 'user_id-1', '')
    end

    it "should refuse user_id with semicolon" do
      expect {Stream::Feed.new(nil, 'slug', 'user:id', '')}.to raise_error Stream::StreamInputData
    end

    it "should refuse feed_slug with dashes" do
      expect {Stream::Feed.new(nil, 'feed-slug', 'user_id', '')}.to raise_error Stream::StreamInputData
    end

    it "should refuse feed_slug with underscores" do
      expect {Stream::Feed.new(nil, 'feed_slug', 'user_id', '')}.to raise_error Stream::StreamInputData
    end

end
