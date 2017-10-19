require 'spec_helper'
require 'stream'

describe Stream::Client do
  after do
    ENV.delete 'STREAM_URL'
  end

  it 'feed returns a Feed instance with id' do
    client = Stream::Client.new('key', 'secret')
    client.api_key.should eq 'key'
    client.api_secret.should eq 'secret'
    feed = client.feed('feed', '42')
    expect(feed).to be_instance_of Stream::Feed
    feed.user_id.should eq '42'
    feed.slug.should eq 'feed'
    feed.id.should eq 'feed:42'
  end

  it 'on heroku we connect using environment variables' do
    ENV['STREAM_URL'] = 'https://thierry:pass@stream-io-api.com/?app_id=1'
    client = Stream::Client.new
    client.api_key.should eq 'thierry'
    client.api_secret.should eq 'pass'
    client.app_id.should eq '1'
    client.client_options[:location].should eq nil
    client.get_http_client.conn.url_prefix.to_s.should eq 'https://api.stream-io-api.com/api/v1.0'
  end

  it 'old heroku url' do
    ENV['STREAM_URL'] = 'https://thierry:pass@api.stream-io-api.com/?app_id=1'
    client = Stream::Client.new
    client.api_key.should eq 'thierry'
    client.api_secret.should eq 'pass'
    client.app_id.should eq '1'
    client.client_options[:location].should eq nil
    client.get_http_client.conn.url_prefix.to_s.should eq 'https://api.stream-io-api.com/api/v1.0'
  end

  it 'heroku url with location' do
    ENV['STREAM_URL'] = 'https://thierry:pass@eu-west.stream-io-api.com/?app_id=1'
    client = Stream::Client.new
    client.api_key.should eq 'thierry'
    client.api_secret.should eq 'pass'
    client.app_id.should eq '1'
    client.client_options[:location].should eq 'eu-west'
    client.get_http_client.conn.url_prefix.to_s.should eq 'https://eu-west-api.stream-io-api.com/api/v1.0'
  end

  it 'heroku with getstream.io url with location' do
    ENV['STREAM_URL'] = 'https://thierry:pass@eu-west.getstream.io/?app_id=1'
    client = Stream::Client.new
    client.api_key.should eq 'thierry'
    client.api_secret.should eq 'pass'
    client.app_id.should eq '1'
    client.client_options[:location].should eq 'eu-west'
    client.get_http_client.conn.url_prefix.to_s.should eq 'https://eu-west-api.getstream.io/api/v1.0'
  end

  it 'heroku url with location and extra vars' do
    ENV['STREAM_URL'] = 'https://thierry:pass@eu-west.stream-io-api.com/?something_else=2&app_id=1&something_more=3'
    client = Stream::Client.new
    client.api_key.should eq 'thierry'
    client.api_secret.should eq 'pass'
    client.app_id.should eq '1'
    client.client_options[:location].should eq 'eu-west'
    client.get_http_client.conn.url_prefix.to_s.should eq 'https://eu-west-api.stream-io-api.com/api/v1.0'
  end

  it 'wrong heroku vars' do
    ENV['STREAM_URL'] = 'https://thierry:pass@stream-io-api.com/?a=1'
    expect {Stream::Client.new}.to raise_error(ArgumentError)
  end

  it 'but overwriting environment variables should be possible' do
    ENV['STREAM_URL'] = 'https://thierry:pass@stream-io-api.com/?app_id=1'
    client = Stream::Client.new('1', '2', '3')
    client.api_key.should eq '1'
    client.api_secret.should eq '2'
    client.app_id.should eq '3'
    ENV.delete 'STREAM_URL'
  end

  it 'should handle different api versions if specified' do
    client = Stream::Client.new('1', '2', nil, :api_version => 'v2.345')
    http_client = client.get_http_client
    http_client.conn.url_prefix.to_s.should eq 'https://api.stream-io-api.com/api/v2.345'
  end

  it 'should handle default location as api.stream-io-api.com' do
    client = Stream::Client.new('1', '2')
    http_client = client.get_http_client
    http_client.conn.url_prefix.to_s.should eq 'https://api.stream-io-api.com/api/v1.0'
  end

  it 'should handle overriding default hostname as api.getstream.io to test SNI' do
    client = Stream::Client.new('1', '2', nil,api_hostname: 'getstream.io')
    http_client = client.get_http_client
    http_client.conn.url_prefix.to_s.should eq 'https://api.getstream.io/api/v1.0'
  end

  it 'should handle us-east location as api.stream-io-api.com' do
    client = Stream::Client.new('1', '2', nil, :location => 'us-east')
    http_client = client.get_http_client
    http_client.conn.url_prefix.to_s.should eq 'https://us-east-api.stream-io-api.com/api/v1.0'
  end

  it 'should have 3s default timeout' do
    client = Stream::Client.new('1', '2', nil)
    http_client = client.get_http_client
    http_client.conn.options[:timeout].should eq 3
  end

  it 'should be possible to change timeout' do
    client = Stream::Client.new('1', '2', nil, :default_timeout => 5)
    http_client = client.get_http_client
    http_client.conn.options[:timeout].should eq 5
  end
end
