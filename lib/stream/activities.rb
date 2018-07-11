module Stream
  module Activities

    #
    # Get activities directly, via ID or Foreign ID + timestamp
    #
    # @param [Hash<:ids, :foreign_ids, :timestamps>] params the request params (ids or foreign_ids + timestamps)
    #
    # @return the found activities, if any.
    #
    # @example
    #
    #
    # @client.get_activities({
    #   ids: [ '4b39fda2-d6e2-42c9-9abf-5301ef071b12', '89b910d3-1ef5-44f8-914e-e7735d79e817' ]
    # })
    #
    # @client.get_activities({
    #   foreign_ids: [ 'post:1000',                  'like:2000' ]
    #   timestamps:  [ '2016-11-10T13:20:00.000000', '2018-01-07T09:15:59.123456' ]
    # })
    #
    def get_activities(params = {})
      signature = Stream::Signer.create_jwt_token('activities', '*', @api_secret, '*')
      make_request(:get, '/activities/', signature, params)
    end

    #
    # Partial update activity, via foreign ID or Foreign ID + timestamp
    #
    # @param [Hash<:id, :foreign_id, :time, :set, :unset>] data the request params (id and foreign_id+timestamp mutually exclusive)
    #
    # @return the updated activity.
    #
    # @example
    #
    # @client.update_activity_partial(
    #   id: "4b39fda2-d6e2-42c9-9abf-5301ef071b12",
    #   set: {
    #    "product.price.eur": 12.99,
    #    "colors": {
    #      "blue": "#0000ff",
    #      "green": "#00ff00",
    #    }
    #   },
    #   unset: [ "popularity", "size.xl" ]
    # )
    #
    # @client.update_activity_partial(
    #   foreign_id: 'product:123',
    #   time: '2016-11-10T13:20:00.000000',
    #   set: {
    #    "product.price.eur": 12.99,
    #    "colors": {
    #      "blue": "#0000ff",
    #      "green": "#00ff00",
    #    }
    #   },
    #   unset: [ "popularity", "size.xl" ]
    # )
    def update_activity_partial(data = {})
      signature = Stream::Signer.create_jwt_token('activities', '*', @api_secret, '*')
      make_request(:post, '/activity/', signature, {}, data)
    end

  end
end
