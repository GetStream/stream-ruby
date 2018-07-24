module Stream
  module Activities

    #
    # Get activities directly, via ID or Foreign ID + timestamp
    #
    # @param [Hash<:ids, :foreign_id_times>] params the request params (ids or list of <:foreign_id, :time> objects)
    #
    # @return the found activities, if any.
    #
    # @example
    #
    #
    # @client.get_activities(
    #   ids: [
    #     '4b39fda2-d6e2-42c9-9abf-5301ef071b12',
    #     '89b910d3-1ef5-44f8-914e-e7735d79e817'
    #   ]
    # )
    #
    # @client.get_activities(
    #   foreign_id_times: [
    #     { foreign_id: 'post:1000', time: '2016-11-10T13:20:00.000000' },
    #     { foreign_id: 'like:2000', time: '2018-01-07T09:15:59.123456' }
    #   ]
    # )
    #
    def get_activities(params = {})
      if params[:foreign_id_times]
        foreign_ids = []
        timestamps = []
        params[:foreign_id_times].each{|e|
          foreign_ids << e[:foreign_id]
          timestamps << e[:time]
        }
        params = {
          foreign_ids: foreign_ids,
          timestamps: timestamps,
        }
      end
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
    # @client.activity_partial_update(
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
    # @client.activity_partial_update(
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
    def activity_partial_update(data = {})
      signature = Stream::Signer.create_jwt_token('activities', '*', @api_secret, '*')
      make_request(:post, '/activity/', signature, {}, data)
    end

  end
end
