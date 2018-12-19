module Stream
  class ReactionsClient < Client
    def add(kind, activity_id, user_id, data: nil, target_feeds: nil)
      data = {
        kind: kind,
        activity_id: activity_id,
        user_id: user_id,
        data: data,
        target_feeds: target_feeds
      }
      make_reaction_request(:post, {}, data)
    end

    def get(reaction_id)
      uri = "/reaction/#{reaction_id}/"
      make_reaction_request(:get, {}, {}, :endpoint => uri)
    end

    def update(reaction_id, data: nil, target_feeds: nil)
      data = {
        data: data,
        target_feeds: target_feeds
      }
      uri = "/reaction/#{reaction_id}/"
      make_reaction_request(:put, {}, data, :endpoint => uri)
    end

    def delete(reaction_id)
      uri = "/reaction/#{reaction_id}/"
      make_reaction_request(:delete, {}, {}, :endpoint => uri)
    end

    def add_child(kind, parent_id, user_id, data: nil, target_feeds: nil)
      data = {
        kind: kind,
        parent: parent_id,
        user_id: user_id,
        data: data,
        target_feeds: target_feeds
      }
      make_reaction_request(:post, {}, data)
    end

    def filter(params = {})
      lookup_field = ""
      lookup_value = ""
      kind = params.fetch(:kind, "")
      if params[:reaction_id]
        lookup_field = "reaction_id"
        lookup_value = params[:reaction_id]
      elsif params[:activity_id]
        lookup_field = "activity_id"
        lookup_value = params[:activity_id]
      elsif params[:user_id]
        lookup_field = "user_id"
        lookup_value = params[:user_id]
      end
      unless lookup_field.empty?
        params.delete(lookup_field.to_sym)
      end
      if kind.nil? || kind.empty?
        uri = "/reaction/#{lookup_field}/#{lookup_value}/"
      else
        uri = "/reaction/#{lookup_field}/#{lookup_value}/#{kind}/"
      end
      make_reaction_request(:get, params, {}, :endpoint => uri)
    end

    def create_reference(id)
      _id = id
      if id.respond_to?(:keys) and !id["id"].nil?
        _id = id["id"]
      end
      "SR:#{_id}"
    end

    private

    def make_reaction_request(method, params, data, endpoint: '/reaction/')
      auth_token = Stream::Signer.create_jwt_token('reactions', '*', @api_secret, '*', '*')
      make_request(method, endpoint, auth_token, params, data)
    end
  end
end
