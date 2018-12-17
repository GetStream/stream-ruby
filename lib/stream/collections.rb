module Stream
  class CollectionsClient < Client
    def add(collection_name, collection_data, id: nil, user_id: nil)
      data = {
        id: id,
        user_id: user_id,
        data: collection_data,
      }
      uri = "/collections/#{collection_name}/"
      make_collection_request(:post, {}, data, :endpoint => uri)
    end

    def get(collection_name, id)
      uri = "collections/#{collection_name}/#{id}/"
      make_collection_request(:get, {}, {}, :endpoint => uri)
    end

    def update(collection_name, id, data: nil)
      data = {
        data: data
      }
      uri = "collections/#{collection_name}/#{id}/"
      make_collection_request(:put, {}, data, :endpoint => uri)
    end

    def delete(collection_name, id)
      uri = "collections/#{collection_name}/#{id}/"
      make_collection_request(:delete, {}, {}, :endpoint => uri)
    end

    def upsert(collection, objects = [])
      data = {
        data: {
          collection => objects
        }
      }
      make_collection_request(:post, {}, data)
    end

    def select(collection, ids = [])
      params = {
        foreign_ids: ids.map { |id| "#{collection}:#{id}" }.join(',')
      }
      make_collection_request(:get, params, {})
    end

    def delete_many(collection, ids = [])
      params = {
        collection_name: collection,
        ids: ids.join(',')
      }
      make_collection_request(:delete, params, {})
    end

    def create_reference(collection, id)
      _id = id
      if id.respond_to?(:keys) and !id["id"].nil?
        _id = id["id"]
      end
      "SO:#{collection}:#{_id}"
    end

    private

    def make_collection_request(method, params, data, endpoint: '/collections/')
      auth_token = Stream::Signer.create_jwt_token('collections', '*', @api_secret, '*', '*')
      make_request(method, endpoint, auth_token, params, data)
    end
  end
end
