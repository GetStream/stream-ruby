require "httparty"
require "stream/exceptions"
require "stream/feed"
require "stream/signer"

module Stream
  STREAM_URL_RE = %r{https\:\/\/(?<key>\w+)\:(?<secret>\w+)@((api\.)|((?<location>[-\w]+)\.))?getstream\.io\/[\w=-\?%&]+app_id=(?<app_id>\d+)}i

  class Client
    attr_reader :api_key
    attr_reader :api_secret
    attr_reader :app_id
    attr_reader :api_version
    attr_reader :location
    attr_reader :default_timeout

    if RUBY_VERSION.to_f >= 2.1
      require "stream/batch"
      require "stream/signedrequest"

      include Stream::SignedRequest
      include Stream::Batch
    end

    #
    # initializes a Stream API Client
    #
    # @param [string] api_key your application api_key
    # @param [string] api_secret your application secret
    # @param [string] app_id the id of your application (optional)
    # @param [hash] opts extra options
    #
    # @example initialise the client to connect to EU-West location
    #   Stream::Client.new('my_key', 'my_secret', 'my_app_id', :location => 'us-east')
    #
    def initialize(api_key = "", api_secret = "", app_id = nil, opts = {})
      if ENV["STREAM_URL"] =~ Stream::STREAM_URL_RE && (api_key.nil? || api_key.empty?)
        matches = Stream::STREAM_URL_RE.match(ENV["STREAM_URL"])
        api_key = matches["key"]
        api_secret = matches["secret"]
        app_id = matches["app_id"]
        opts[:location] = matches["location"]
      end

      if api_key.nil? || api_key.empty?
        raise ArgumentError, "empty api_key parameter and missing or invalid STREAM_URL env variable"
      end

      @api_key = api_key
      @api_secret = api_secret
      @app_id = app_id
      @location = opts[:location]
      @api_version = opts.fetch(:api_version, "v1.0")
      @default_timeout = opts.fetch(:default_timeout, 3)
      @signer = Stream::Signer.new(api_secret)
    end

    #
    # Creates a feed instance
    #
    # @param [string] feed_slug the feed slug (eg. flat, aggregated...)
    # @param [user_id] user_id the user_id of this feed (eg. User42)
    #
    # @return [Stream::Feed]
    #
    def feed(feed_slug, user_id)
      token = @signer.sign(feed_slug, user_id)
      Stream::Feed.new(self, feed_slug, user_id, token)
    end

    def get_default_params
      { :api_key => @api_key }
    end

    def get_http_client
      StreamHTTPClient.new(@api_version, @location, @default_timeout)
    end

    def make_query_params(params)
      get_default_params.merge(params)
    end

    def make_request(method, relative_url, signature, params = {}, data = {}, headers = {})
      headers["Authorization"] = signature
      get_http_client.make_http_request(method, relative_url, make_query_params(params), data, headers)
    end
  end

  class StreamHTTPClient
    include HTTParty
    attr_reader :base_path

    def initialize(api_version = "v1.0", location = nil, default_timeout = 3)
      if location.nil?
        location_name = "api"
      else
        location_name = "#{location}-api"
      end
      @base_path = "/api/#{api_version}"
      self.class.base_uri "https://#{location_name}.getstream.io#{@base_path}"
      self.class.default_timeout default_timeout
    end

    def make_http_request(method, relative_url, params = nil, data = nil, headers = nil)
      headers["Content-Type"] = "application/json"
      headers["X-Stream-Client"] = "stream-ruby-#{Stream::VERSION}"
      body = data.to_json if ["post", "put"].include? method.to_s
      response = self.class.send(method, relative_url, :headers => headers, :query => params, :body => body)
      case response.code
      when 200..203
        return response
      when 204...600
        raise StreamApiResponseException, "#{response['exception']} details: #{response['detail']}"
      end
    end
  end
end
