require "http_signatures"
require "net/http"
require "time"

module Stream
  module SignedRequest
    module ClassMethods
        def supports_signed_requests
        end
    end

    def self.included(klass)
        klass.extend ClassMethods
    end

    def make_signed_request(method, relative_url, params={}, data={})
        query_params = self.make_query_params(params)
        context = HttpSignatures::Context.new(
            keys: {@api_key => @api_secret},
            algorithm: "hmac-sha256",
            headers: ["(request-target)", "Date"],
        )
        method_map = {
            :get => Net::HTTP::Get,
            :delete => Net::HTTP::Delete,
            :put => Net::HTTP::Put,
            :post => Net::HTTP::Post,
        }
        request_date = Time.now.rfc822
        message = method_map[method].new(
          "#{self.get_http_client.base_path}#{relative_url}?#{URI.encode_www_form(query_params)}",
          'Date' => request_date,
        )
        context.signer.sign(message)
        headers = {
            'Authorization' => message["Signature"],
            'Date' => request_date,
            'X-Api-Key' => self.api_key
        }
        self.get_http_client.make_http_request(method, relative_url, query_params, data, headers)
    end
  end
end
