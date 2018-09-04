module Stream
  class CollectionsClient < Client
    def upsert(collection, objects = [])
      data = {
        data: {
          collection => objects
        }
      }
      make_collection_request(:post, {}, data)
    end

    def get(collection, ids = [])
      params = {
        foreign_ids: ids.map { |id| "#{collection}:#{id}" }.join(',')
      }
      make_collection_request(:get, params, {})
    end

    def delete(collection, ids = [])
      params = {
        collection_name: collection,
        ids: ids.join(',')
      }
      make_collection_request(:delete, params, {})
    end

    def create_reference(collection, id)
      "SO:#{collection}:#{id}"
    end

    def create_user_reference(id)
      create_reference('user', id)
    end

    private

    def make_collection_request(method, params, data)
      endpoint = '/meta/'
      auth_token = Stream::Signer.create_jwt_token('collections', '*', @api_secret, '*', '*')
      make_request(method, endpoint, auth_token, params, data)
    end
  end
end
