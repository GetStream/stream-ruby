require "faraday"
require "stream/errors"
require "stream/feed"
require "stream/signer"

module Stream
  STREAM_URL_RE = %r{https\:\/\/(?<key>\w+)\:(?<secret>\w+)@((api\.)|((?<location>[-\w]+)\.))?getstream\.io\/[\w=-\?%&]+app_id=(?<app_id>\d+)}i

  class Client
    attr_reader :api_key
    attr_reader :api_secret
    attr_reader :app_id
    attr_reader :client_options

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
      @signer = Stream::Signer.new(api_secret)

      @client_options = {
        :api_version => opts.fetch(:api_version, "v1.0"),
        :location => opts.fetch(:location, nil),
        :default_timeout => opts.fetch(:default_timeout, 3),
        :api_key => @api_key
      }
    end

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

    def update_activity(activity)
      update_activities([activity])
    end

    def update_activities(activities)
      auth_token = Stream::Signer.create_jwt_token("activities", "*", @api_secret, "*")
      make_request(:post, "/activities/", auth_token, {}, "activities" => activities)
    end

    def get_default_params
      { :api_key => @api_key }
    end

    def get_http_client
      @http_client ||= StreamHTTPClient.new(@client_options)
    end

    def make_query_params(params)
      get_default_params.merge(params)
    end

    def make_request(method, relative_url, signature, params = {}, data = {}, headers = {})
      headers["Authorization"] = signature
      headers["stream-auth-type"] = "jwt"

      get_http_client.make_http_request(method, relative_url, make_query_params(params), data, headers)
    end
  end

  class StreamHTTPClient
    require "faraday"

    attr_reader :conn
    attr_reader :options
    attr_reader :base_path

    def initialize(client_params)
      @options = client_params
      location_name = "api"
      unless client_params[:location].nil?
        location_name = "#{client_params[:location]}-api"
      end

      protocol = "https"
      if @options[:location] == "qa"
        protocol = "http"
      end

      @base_path = "/api/#{@options[:api_version]}"
      base_url = "#{protocol}://#{location_name}.getstream.io#{@base_path}"

      @conn = Faraday.new(:url => base_url) do |faraday|
        # faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.use RaiseHttpException
        faraday.options[:open_timeout] = @options[:default_timeout]
        faraday.options[:timeout] = @options[:default_timeout]
      end
      @conn.path_prefix = @base_path
    end

    def make_http_request(method, relative_url, params = nil, data = nil, headers = nil)
      headers["Content-Type"] = "application/json"
      headers["X-Stream-Client"] = "stream-ruby-client-#{Stream::VERSION}"

      params["api_key"] = @options[:api_key]
      relative_url = "#{@base_path}#{relative_url}?#{URI.encode_www_form(params)}"
      response = @conn.run_request(method, relative_url, data.to_json, headers)

      case response[:status].to_i
      when 200..203
        return ::JSON.parse(response[:body])
      end
    end
  end

  class RaiseHttpException < Faraday::Middleware
    def call(env)
      @app.call(env).on_complete do |response|
        case response[:status].to_i
        when 200..203
          return response
        when 401
          raise StreamApiResponseException, error_message(response, "Bad feed")
        when 403
          raise StreamApiResponseException, error_message(response, "Bad auth/headers")
        when 404
          raise StreamApiResponseException, error_message(response, "url not found")
        when 204...600
          raise StreamApiResponseException, error_message(response, "something else")
        end
      end
    end

    def initialize(app)
      super app
      @parser = nil
    end

    private

    def error_message(response, body = nil)
      "#{response[:method].to_s.upcase} #{response[:url]}: #{[response[:status].to_s + ':', body].compact.join(' ')}"
    end

    def error_body(body)
      if !body.nil? && !body.empty? && body.is_a?(String)
        body = ::JSON.parse(body)
      end

      if body.nil?
        nil
      elsif body["meta"] && body["meta"]["error_message"] && !body["meta"]["error_message"].empty?
        ": #{body['meta']['error_message']}"
      elsif body["error_message"] && !body["error_message"].empty?
        ": #{body['error_type']}: #{body['error_message']}"
      end
    end
  end
end
