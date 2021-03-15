require 'spec_helper'
require 'stream'

describe Stream::Client do
  before do
    @env_url = ENV['STREAM_URL']
  end

  after do
    ENV.delete 'STREAM_URL'
    ENV['STREAM_URL'] = @env_url if @env_url
  end

  it 'feed returns a Feed instance with id' do
    client = Stream::Client.new('key', 'secret')
    expect(client.api_key).to eq 'key'
    expect(client.api_secret).to eq 'secret'
    feed = client.feed('feed', '42')
    expect(feed).to be_instance_of Stream::Feed
    expect(feed.user_id).to eq '42'
    expect(feed.slug).to eq 'feed'
    expect(feed.id).to eq 'feed:42'
  end

  it 'check user_token' do
    client = Stream::Client.new('key', 'secret')
    user_token = client.create_user_session_token('user')
    expect(user_token).to eq 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoidXNlciJ9.vSdu-exEFUWts57olfk9X_I1CytXuXrRF7A0LpQmoaM'
    payload = JWT.decode(user_token, 'secret', 'HS256')
    expect(payload[0]['user_id']).to eq 'user'
    user_token = client.create_user_token('user')
    expect(user_token).to eq 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoidXNlciJ9.vSdu-exEFUWts57olfk9X_I1CytXuXrRF7A0LpQmoaM'
    payload = JWT.decode(user_token, 'secret', 'HS256')
    expect(payload[0]['user_id']).to eq 'user'
    user_token = client.create_user_token('user', { 'client' => 'ruby', 'testing' => true })
    expect(user_token).to eq 'eyJhbGciOiJIUzI1NiJ9.eyJjbGllbnQiOiJydWJ5IiwidGVzdGluZyI6dHJ1ZSwidXNlcl9pZCI6InVzZXIifQ.cDEffbaTeBO6HWH602wHA6RCKTo5K0gFR50vzfQdW8k'
    payload = JWT.decode(user_token, 'secret', 'HS256')
    expect(payload[0]['user_id']).to eq 'user'
    expect(payload[0]['client']).to eq 'ruby'
    expect(payload[0]['testing']).to eq true
  end

  it 'on heroku we connect using environment variables' do
    ENV['STREAM_URL'] = 'https://thierry:pass@stream-io-api.com/?app_id=1'
    client = Stream::Client.new
    expect(client.api_key).to eq 'thierry'
    expect(client.api_secret).to eq 'pass'
    expect(client.app_id).to eq '1'
    expect(client.client_options[:location]).to be_nil
    expect(client.get_http_client.conn.url_prefix.to_s).to eq 'https://api.stream-io-api.com/api/v1.0'
  end

  it 'old heroku url' do
    ENV['STREAM_URL'] = 'https://thierry:pass@api.stream-io-api.com/?app_id=1'
    client = Stream::Client.new
    expect(client.api_key).to eq 'thierry'
    expect(client.api_secret).to eq 'pass'
    expect(client.app_id).to eq '1'
    expect(client.client_options[:location]).to be_nil
    expect(client.get_http_client.conn.url_prefix.to_s).to eq 'https://api.stream-io-api.com/api/v1.0'
  end

  it 'heroku url with location' do
    ENV['STREAM_URL'] = 'https://thierry:pass@eu-west.stream-io-api.com/?app_id=1'
    client = Stream::Client.new
    expect(client.api_key).to eq 'thierry'
    expect(client.api_secret).to eq 'pass'
    expect(client.app_id).to eq '1'
    expect(client.client_options[:location]).to eq 'eu-west'
    expect(client.get_http_client.conn.url_prefix.to_s).to eq 'https://eu-west-api.stream-io-api.com/api/v1.0'
  end

  it 'heroku with getstream.io url with location' do
    ENV['STREAM_URL'] = 'https://thierry:pass@eu-west.getstream.io/?app_id=1'
    client = Stream::Client.new
    expect(client.api_key).to eq 'thierry'
    expect(client.api_secret).to eq 'pass'
    expect(client.app_id).to eq '1'
    expect(client.client_options[:location]).to eq 'eu-west'
    expect(client.get_http_client.conn.url_prefix.to_s).to eq 'https://eu-west-api.getstream.io/api/v1.0'
  end

  it 'heroku url with location and extra vars' do
    ENV['STREAM_URL'] = 'https://thierry:pass@eu-west.stream-io-api.com/?something_else=2&app_id=1&something_more=3'
    client = Stream::Client.new
    expect(client.api_key).to eq 'thierry'
    expect(client.api_secret).to eq 'pass'
    expect(client.app_id).to eq '1'
    expect(client.client_options[:location]).to eq 'eu-west'
    expect(client.get_http_client.conn.url_prefix.to_s).to eq 'https://eu-west-api.stream-io-api.com/api/v1.0'
  end

  it 'wrong heroku vars' do
    ENV['STREAM_URL'] = 'https://thierry:pass@stream-io-api.com/?a=1'
    expect { Stream::Client.new }.to raise_error(ArgumentError)
  end

  it 'but overwriting environment variables should be possible' do
    ENV['STREAM_URL'] = 'https://thierry:pass@stream-io-api.com/?app_id=1'
    client = Stream::Client.new('1', '2', '3')
    expect(client.api_key).to eq '1'
    expect(client.api_secret).to eq '2'
    expect(client.app_id).to eq '3'
    ENV.delete 'STREAM_URL'
  end

  it 'should handle different api versions if specified' do
    client = Stream::Client.new('1', '2', nil, api_version: 'v2.345')
    http_client = client.get_http_client
    expect(http_client.conn.url_prefix.to_s).to eq 'https://api.stream-io-api.com/api/v2.345'
  end

  it 'should handle default location as api.stream-io-api.com' do
    client = Stream::Client.new('1', '2')
    http_client = client.get_http_client
    expect(http_client.conn.url_prefix.to_s).to eq 'https://api.stream-io-api.com/api/v1.0'
  end

  it 'should handle overriding default hostname as api.getstream.io to test SNI' do
    client = Stream::Client.new('1', '2', nil, api_hostname: 'getstream.io')
    http_client = client.get_http_client
    expect(http_client.conn.url_prefix.to_s).to eq 'https://api.getstream.io/api/v1.0'
  end

  it 'should handle us-east location as api.stream-io-api.com' do
    client = Stream::Client.new('1', '2', nil, location: 'us-east')
    http_client = client.get_http_client
    expect(http_client.conn.url_prefix.to_s).to eq 'https://us-east-api.stream-io-api.com/api/v1.0'
  end

  it 'should have 3s default timeout' do
    client = Stream::Client.new('1', '2', nil)
    http_client = client.get_http_client
    expect(http_client.conn.options[:timeout]).to eq 3
  end

  it 'should be possible to change timeout' do
    client = Stream::Client.new('1', '2', nil, default_timeout: 5)
    http_client = client.get_http_client
    expect(http_client.conn.options[:timeout]).to eq 5
  end
end
