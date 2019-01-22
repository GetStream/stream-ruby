require 'faraday'
require 'stream/errors'
require 'stream/feed'
require 'stream/signer'
require 'stream/url'

module Stream
  STREAM_URL_COM_RE = %r{https\:\/\/(?<key>\w+)\:(?<secret>\w+)@((api\.)|((?<location>[-\w]+)\.))?(?<api_hostname>stream-io-api\.com)\/[\w=-\?%&]+app_id=(?<app_id>\d+)}i
  STREAM_URL_IO_RE = %r{https\:\/\/(?<key>\w+)\:(?<secret>\w+)@((api\.)|((?<location>[-\w]+)\.))?(?<api_hostname>getstream\.io)\/[\w=-\?%&]+app_id=(?<app_id>\d+)}i

  class Client
    attr_reader :api_key
    attr_reader :api_secret
    attr_reader :app_id
    attr_reader :client_options

    require 'stream/batch'
    require 'stream/personalization'
    require 'stream/collections'
    require 'stream/activities'
    require 'stream/reactions'
    require 'stream/users'

    include Stream::Batch
    include Stream::Activities

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
    def initialize(api_key = '', api_secret = '', app_id = nil, opts = {})

      if api_key.nil? || api_key.empty?
        env_url = ENV['STREAM_URL']
        if env_url =~ Stream::STREAM_URL_COM_RE
          re = Stream::STREAM_URL_COM_RE
        elsif env_url =~ Stream::STREAM_URL_IO_RE
          re = Stream::STREAM_URL_IO_RE
        end
        raise ArgumentError, 'empty api_key parameter and missing or invalid STREAM_URL env variable' unless re

        matches = re.match(ENV['STREAM_URL'])
        api_key = matches['key']
        api_secret = matches['secret']
        app_id = matches['app_id']
        opts[:location] = matches['location']
        opts[:api_hostname] = matches['api_hostname']
      end

      @api_key = api_key
      @api_secret = api_secret
      @app_id = app_id
      @signer = Stream::Signer.new(api_secret)

      @client_options = {
        api_key: @api_key,
        api_version: opts[:api_version] || 'v1.0',
        location: opts[:location],
        default_timeout: opts[:default_timeout] || 3,
        api_hostname: opts[:api_hostname] || 'stream-io-api.com'
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
      Stream::Feed.new(self, feed_slug, user_id)
    end

    # Creates a user token
    #
    # @deprecated Use Client#create_user_token instead
    #
    # @param [string] user_id the user_if of this token (e.g. User42)
    # @param [hash] extra_data additional token data
    #
    # @return [string]
    #
    def create_user_session_token(user_id, extra_data = {})
      create_user_token(user_id, extra_data)
    end

    # Creates a user token
    #
    # @param [string] user_id the user_if of this token (e.g. User42)
    # @param [hash] extra_data additional token data
    #
    # @return [string]
    #
    def create_user_token(user_id, extra_data = {})
      return Stream::Signer.create_user_token(user_id, extra_data, api_secret)
    end

    def personalization
      PersonalizationClient.new(api_key, api_secret, app_id, client_options)
    end

    def collections
      CollectionsClient.new(api_key, api_secret, app_id, client_options)
    end

    def reactions
      ReactionsClient.new(api_key, api_secret, app_id, client_options)
    end

    def users
      UsersClient.new(api_key, api_secret, app_id, client_options)
    end

    def update_activity(activity)
      update_activities([activity])
    end

    def update_activities(activities)
      auth_token = Stream::Signer.create_jwt_token('activities', '*', @api_secret, '*')
      make_request(:post, '/activities/', auth_token, {}, 'activities' => activities)
    end

    def get_default_params
      {:api_key => @api_key}
    end

    def get_http_client
      @http_client ||= StreamHTTPClient.new(url_generator)
    end

    def make_query_params(params)
      Hash[get_default_params.merge(params).sort_by {|k, v| k.to_s}]
    end

    def make_request(method, relative_url, signature, params = {}, data = {}, headers = {})
      headers['Authorization'] = signature
      headers['stream-auth-type'] = 'jwt'
      get_http_client.make_http_request(method, relative_url, make_query_params(params), data, headers)
    end

    private

    def url_generator
      APIURLGenerator.new(@client_options)
    end
  end

  class StreamHTTPClient
    require 'faraday'

    attr_reader :conn
    attr_reader :options
    attr_reader :base_path

    def initialize(url_generator)
      @options = url_generator.options
      @conn = Faraday.new(url: url_generator.url) do |faraday|
        faraday.use RaiseHttpException
        faraday.options[:open_timeout] = @options[:default_timeout]
        faraday.options[:timeout] = @options[:default_timeout]
        faraday.adapter Faraday.default_adapter
      end
      @base_path = url_generator.base_path
      @conn.path_prefix = base_path
    end

    def make_http_request(method, relative_url, params = nil, data = nil, headers = nil)
      headers['Content-Type'] = 'application/json'
      headers['X-Stream-Client'] = "stream-ruby-client-#{Stream::VERSION}"
      base_url = [base_path, relative_url].join('/').gsub(%r{/+}, '/')
      url = "#{base_url}?#{URI.encode_www_form(params)}"
      body = data.to_json if %w[post put].include? method.to_s
      response = @conn.run_request(
        method,
        url,
        body,
        headers
      )

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
            raise StreamApiResponseException, error_message(response, 'Bad feed')
          when 403
            raise StreamApiResponseException, error_message(response, 'Bad auth/headers')
          when 404
            raise StreamApiResponseException, error_message(response, 'url not found')
          when 204...600
            raise StreamApiResponseException, error_message(response, _build_error_message(response.body))
        end
      end
    end

    def initialize(app)
      super app
      @parser = nil
    end

    private

    def _build_error_message(response)
      response = JSON.parse(response)
      msg = "#{response['exception']} details: #{response['detail']}"
      if response.key?('exception_fields')
        response['exception_fields'].map do |field, messages|
          msg << "\n#{field}: #{messages}"
        end
      end
      msg
    end

    def error_message(response, body = nil)
      "#{response[:method].to_s.upcase} #{response[:url]}: #{[response[:status].to_s + ':', body].compact.join(' ')}"
    end
  end
end
