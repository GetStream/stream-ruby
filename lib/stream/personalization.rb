require 'stream/url'

module Stream
  class PersonalizationClient < Client
    def url_generator
      PersonalizationURLGenerator.new(@client_options)
    end

    def get(resource, params = {})
      make_personalization_request(:get, resource, params, {})
    end

    def post(resource, params = {}, data = {})
      make_personalization_request(:post, resource, params, data: data)
    end

    def delete(resource, params = {})
      make_personalization_request(:delete, resource, params, {})
    end

    private

    def make_personalization_request(method, resource, params, data)
      endpoint = "/#{resource}/"
      auth_token = Stream::Signer.create_jwt_token('personalization', '*', @api_secret, '*', '*')
      make_request(method, endpoint, auth_token, params, data)
    end
  end
end
