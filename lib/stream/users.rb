module Stream
  class UsersClient < Client
    def add(user_id, data: nil, get_or_create: false)
      data = {
        id: user_id,
        data: data
      }
      params = {
        get_or_create: get_or_create
      }
      make_user_request(:post, params, data)
    end

    def get(user_id)
      uri = "/user/#{user_id}/"
      make_user_request(:get, {}, {}, :endpoint => uri)
    end

    def update(user_id, data: nil)
      data = {
        data: data
      }
      uri = "/user/#{user_id}/"
      make_user_request(:put, {}, data, :endpoint => uri)
    end

    def delete(user_id)
      uri = "/user/#{user_id}/"
      make_user_request(:delete, {}, {}, :endpoint => uri)
    end

    def create_reference(id)
      _id = id
      if id.respond_to?(:keys) and !id["id"].nil?
        _id = id["id"]
      end
      "SU:#{_id}"
    end

    private

    def make_user_request(method, params, data, endpoint: '/user/')
      auth_token = Stream::Signer.create_jwt_token('users', '*', @api_secret, '*', '*')
      make_request(method, endpoint, auth_token, params, data)
    end
  end
end
