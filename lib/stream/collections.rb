module Stream
  module Collections
    def upsert_collection_objects(collection, objects = [])
      data = {
        data: {
          collection => objects
        }
      }
      make_collection_request(:post, {}, data)
    end

    def get_collection_objects(collection, ids = [])
      params = {
        foreign_ids: ids.map { |id| "#{collection}:#{id}" }.join(',')
      }
      make_collection_request(:get, params, {})
    end

    def delete_collection_objects(collection, ids = [])
      params = {
        collection_name: collection,
        ids: ids.join(',')
      }
      make_collection_request(:delete, params, {})
    end

    private

    def make_collection_request(method, params, data)
      endpoint = '/meta/'
      auth_token = Stream::Signer.create_jwt_token('collections', '*', @api_secret, '*', '*')
      make_request(method, endpoint, auth_token, params, data)
    end
  end
end
