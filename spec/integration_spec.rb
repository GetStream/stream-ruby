require 'spec_helper'
require 'date'
require './spec/support/utils'

RSpec.configure do |c|
  c.include Utils
end

describe 'Integration tests' do
  before(:all) do
    @client = Stream::Client.new(ENV.fetch('STREAM_API_KEY'), ENV.fetch('STREAM_API_SECRET'), nil, location: ENV.fetch('STREAM_REGION', nil), default_timeout: 10)
    @feed42 = @client.feed('flat', generate_uniq_feed_name)
    @feed43 = @client.feed('flat', generate_uniq_feed_name)

    @test_activity = { actor: 1, verb: 'tweet', object: 1 }
  end

  context 'test client' do
    example 'posting an activity' do
      response = @feed42.add_activity(@test_activity)
      expect(response).to include('id', 'actor', 'verb', 'object', 'target', 'time')
    end

    example 'posting many activities' do
      activities = [
        { actor: 'tommaso', verb: 'tweet', object: 1 },
        { actor: 'thierry', verb: 'tweet', object: 1 }
      ]
      actors = %w[tommaso thierry]
      @feed42.add_activities(activities)
      response = @feed42.get(limit: 5)['results']
      expect([response[0]['actor'], response[1]['actor']]).to match_array(actors)
    end

    example 'mark_seen=true should not mark read' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(actor: 1, verb: 'tweet', object: 1)
      feed.add_activity(actor: 2, verb: 'share', object: 1)
      feed.add_activity(actor: 3, verb: 'run', object: 1)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_seen']).to be false
      expect(response['results'][1]['is_seen']).to be false
      expect(response['results'][2]['is_seen']).to be false
      feed.get(limit: 5, mark_seen: true)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_seen']).to be true #####
      expect(response['results'][1]['is_seen']).to be true #
      expect(response['results'][2]['is_seen']).to be true
      expect(response['results'][0]['is_read']).to be false
      expect(response['results'][1]['is_read']).to be false
      expect(response['results'][2]['is_read']).to be false
    end

    example 'mark_read=true should not mark seen' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(actor: 1, verb: 'tweet', object: 1)
      feed.add_activity(actor: 2, verb: 'share', object: 1)
      feed.add_activity(actor: 3, verb: 'run', object: 1)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_read']).to be false
      expect(response['results'][1]['is_read']).to be false
      expect(response['results'][2]['is_read']).to be false
      feed.get(limit: 5, mark_read: true)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_read']).to be true ##
      expect(response['results'][1]['is_read']).to be true ###
      expect(response['results'][2]['is_read']).to be true
      expect(response['results'][0]['is_seen']).to be false
      expect(response['results'][1]['is_seen']).to be false
      expect(response['results'][2]['is_seen']).to be false
    end

    example 'set feed as read' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(actor: 1, verb: 'tweet', object: 1)
      feed.add_activity(actor: 2, verb: 'share', object: 1)
      feed.add_activity(actor: 3, verb: 'run', object: 1)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_read']).to be false
      expect(response['results'][1]['is_read']).to be false
      expect(response['results'][2]['is_read']).to be false
      feed.get(limit: 5, mark_read: true)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_read']).to be true
      expect(response['results'][1]['is_read']).to be true
      expect(response['results'][2]['is_read']).to be true
    end

    example 'set activities as read' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(actor: 1, verb: 'tweet', object: 1)
      feed.add_activity(actor: 2, verb: 'share', object: 1)
      feed.add_activity(actor: 3, verb: 'run', object: 1)
      response = feed.get(limit: 2)
      ids = response['results'].collect { |a| a['id'] }
      feed.get(limit: 5, mark_read: ids)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_read']).to be true
      expect(response['results'][1]['is_read']).to be true
      expect(response['results'][2]['is_read']).to be false
    end

    example 'set feed as seen' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(actor: 1, verb: 'tweet', object: 1)
      feed.add_activity(actor: 2, verb: 'share', object: 1)
      feed.add_activity(actor: 3, verb: 'run', object: 1)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_seen']).to be false
      expect(response['results'][1]['is_seen']).to be false
      expect(response['results'][2]['is_seen']).to be false ##
      feed.get(limit: 5, mark_seen: true)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_seen']).to be true
      expect(response['results'][1]['is_seen']).to be true
      expect(response['results'][2]['is_seen']).to be true
    end

    example 'set activities as seen' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(actor: 1, verb: 'tweet', object: 1)
      feed.add_activity(actor: 2, verb: 'share', object: 1)
      feed.add_activity(actor: 3, verb: 'run', object: 1)
      response = feed.get(limit: 2)
      ids = response['results'].collect { |a| a['id'] }
      feed.get(limit: 5, mark_seen: ids)
      response = feed.get(limit: 5)
      expect(response['results'][0]['is_seen']).to be true
      expect(response['results'][1]['is_seen']).to be true
      expect(response['results'][2]['is_seen']).to be false
    end

    example 'posting an activity with datetime object' do
      feed = @client.feed('flat', generate_uniq_feed_name)
      activity = { actor: 1, verb: 'tweet', object: 1, time: DateTime.now }
      response = feed.add_activity(activity)
      expect(response).to include('id', 'actor', 'verb', 'object', 'target', 'time')
    end

    example 'localised datetimes should be returned in UTC correctly' do
      feed = @client.feed('flat', generate_uniq_feed_name)
      now = DateTime.now.new_offset(5)
      activity = { actor: 1, verb: 'tweet', object: 1, time: now }
      response = feed.add_activity(activity)
      expect(response).to include('id', 'actor', 'verb', 'object', 'target', 'time')
      response = feed.get(limit: 5)
      expect(DateTime.iso8601(response['results'][0]['time'])).to be_within(1).of(now.new_offset(0))
    end

    example 'posting a custom field as a hash' do
      hash_value = { 'a' => 42 }
      activity = { actor: 1, verb: 'tweet', object: 1, hash_data: hash_value }
      response = @feed42.add_activity(activity)
      expect(response).to include('id', 'actor', 'verb', 'object', 'target', 'hash_data')
      results = @feed42.get(limit: 1)['results']
      expect(results[0]['hash_data']).to eq hash_value
    end

    example 'posting a custom field as a list' do
      list_value = [1, 2, 3]
      activity = { actor: 1, verb: 'tweet', object: 1, hash_data: list_value }
      response = @feed42.add_activity(activity)
      expect(response).to include('id', 'actor', 'verb', 'object', 'target', 'hash_data')
      results = @feed42.get(limit: 1)['results']
      expect(results[0]['hash_data']).to eq list_value
    end

    example 'posting and get one activity' do
      response = @feed42.add_activity(@test_activity)
      results = @feed42.get(limit: 1)['results']
      expect(results[0]['id']).to eq response['id']
    end

    example 'removing an activity' do
      feed = @client.feed('flat', generate_uniq_feed_name)
      response = feed.add_activity(@test_activity)
      results = feed.get(limit: 1)['results']
      expect(results[0]['id']).to eq response['id']
      feed.remove_activity(response['id'])
      results = feed.get(limit: 1)['results']
      expect(results[0]['id']).not_to eq response['id'] if results.count > 0
    end

    example 'removing an activity by foreign_id' do
      activity = { actor: 1, verb: 'tweet', object: 1, foreign_id: 'ruby:42' }
      @feed42.add_activity(activity)
      activity = { actor: 1, verb: 'tweet', object: 1, foreign_id: 'ruby:43' }
      @feed42.add_activity(activity)
      @feed42.remove_activity('ruby:43', foreign_id: true)
      results = @feed42.get(limit: 2)['results']
      expect(results[0]['foreign_id']).to eq 'ruby:42'
    end

    context 'following a feed' do
      context 'should copy an activity' do
        example 'when no copy limit is mentioned' do
          feed1 = @client.feed('flat', '1')
          feed2 = @client.feed('flat', generate_uniq_feed_name)
          feed1.add_activity(@test_activity)
          feed2.follow('flat', '1')
          results = feed2.get['results']
          feed2.unfollow('flat', '1')
          expect(results.length).not_to eq 0
        end
        example 'when a copy limit is given' do
          feed1 = @client.feed('flat', '1')
          feed2 = @client.feed('flat', generate_uniq_feed_name)
          feed1.add_activity(@test_activity)
          feed2.follow('flat', '1', 300)
          results = feed2.get['results']
          feed2.unfollow('flat', '1')
          expect(results.length).not_to eq 0
        end
      end
      context 'should not copy an activity' do
        example 'when limit is set to 0' do
          feed1 = @client.feed('flat', '1')
          feed2 = @client.feed('flat', generate_uniq_feed_name)
          feed1.add_activity(@test_activity)
          feed2.follow('flat', '1', 0)
          results = feed2.get['results']
          expect(results.length).to eq 0
          feed2.unfollow('flat', '1', keep_history: false)
        end
      end
    end

    example 'retrieve feed with no followers' do
      lonely = @client.feed('flat', generate_uniq_feed_name)
      response = lonely.followers
      expect(response['results']).to eq []
    end

    example 'retrieve feed followers with limit and offset' do
      @client.feed('flat', 'r43').follow('flat', 'r123')
      @client.feed('flat', 'r44').follow('flat', 'r123')
      response = @client.feed('flat', 'r123').followers
      expect(response['results'][0]['feed_id']).to eq 'flat:r44'
      expect(response['results'][0]['target_id']).to eq 'flat:r123'
      expect(response['results'][1]['feed_id']).to eq 'flat:r43'
      expect(response['results'][1]['target_id']).to eq 'flat:r123'
    end

    example 'retrieve feed with no followings' do
      asocial = @client.feed('flat', 'rasocial')
      response = asocial.following
      expect(response['results']).to eq []
    end

    example 'retrieve feed followings with limit and offset' do
      social = @client.feed('flat', 'r2social')
      social.follow('flat', 'r43')
      social.follow('flat', 'r44')
      response = social.following(1, 1)
      expect(response['results'][0]['feed_id']).to eq 'flat:r2social'
      expect(response['results'][0]['target_id']).to eq 'flat:r43'
    end

    example 'i dont follow' do
      social = @client.feed('flat', 'rsocial1')
      response = social.following(0, 10, ['flat:asocial'])
      expect(response['results']).to eq []
    end

    example 'do i follow' do
      social = @client.feed('flat', 'rsocial2')
      social.follow('flat', 'r43')
      social.follow('flat', 'r244')
      response = social.following(0, 10, ['flat:r244'])
      expect(response['results'][0]['feed_id']).to eq 'flat:rsocial2'
      expect(response['results'][0]['target_id']).to eq 'flat:r244'
      response = social.following(1, 10, ['flat:r244'])
      expect(response['results']).to eq []
    end

    example 'unfollowing a feed' do
      @feed42.follow('flat', '43')
      @feed42.unfollow('flat', '43')
    end

    example 'unfollowing a feed but keep history' do
      follower = @client.feed('flat', 'keeper')
      follower.follow('flat', 'keepit')
      keepit = @client.feed('flat', 'keepit')
      response = keepit.add_activity(@test_activity)
      follower.get
      follower.unfollow('flat', 'keepit', keep_history: true)
      expect(follower.get['results'][0]['id']).to eq response['id']
    end

    example 'get followers statistics' do
      f = @client.feed('flat', generate_uniq_feed_name)
      f.follow('flat', generate_uniq_feed_name)
      f.follow('flat', generate_uniq_feed_name)
      f.follow('flat', generate_uniq_feed_name)
      stats = f.follow_stats
      expect(stats['results']['following']['count']).to eq 3
      expect(stats['results']['followers']['count']).to eq 0
    end

    example 'posting activity using to' do
      recipient = 'flat', 'toruby11'
      activity = {
        actor: 'tommaso', verb: 'tweet', object: 1, to: [recipient.join(':')]
      }
      @feed42.add_activity(activity)
      target_feed = @client.feed(*recipient)
      response = target_feed.get(limit: 5)['results']
      expect(response[0]['actor']).to eq 'tommaso'
    end

    example 'posting many activities using to' do
      recipient = 'flat', 'toruby1'
      activities = [
        { actor: 'tommaso', verb: 'tweet', object: 1, to: [recipient.join(':')] },
        { actor: 'thierry', verb: 'tweet', object: 1, to: [recipient.join(':')] }
      ]
      actors = %w[tommaso thierry]
      @feed42.add_activities(activities)
      target_feed = @client.feed(*recipient)
      response = target_feed.get(limit: 5)['results']
      expect([response[0]['actor'], response[1]['actor']]).to match_array(actors)
    end

    example 'update to targets' do
      foreign_id = 'user:1'
      time = DateTime.now
      activity = {
        actor: 'tommaso',
        verb: 'tweet',
        object: 1,
        to: ['user:1', 'user:2'],
        foreign_id: foreign_id,
        time: time
      }
      @feed42.add_activity(activity)

      response = @feed42.update_activity_to_targets(
        foreign_id, time, new_targets: ['user:3', 'user:2']
      )
      expect(response['activity']['to'].length).to eq 2
      expect(response['activity']['to']).to include('user:2')
      expect(response['activity']['to']).to include('user:3')

      response = @feed42.update_activity_to_targets(
        foreign_id,
        time,
        added_targets: ['user:4', 'user:5'],
        removed_targets: ['user:3']
      )
      expect(response['activity']['to'].length).to eq 3
      expect(response['activity']['to']).to include('user:2')
      expect(response['activity']['to']).to include('user:4')
      expect(response['activity']['to']).to include('user:5')
    end

    example 'read from a feed' do
      @feed42.get
      @feed42.get(limit: 5)
      @feed42.get(offset: 4, limit: 5)
    end

    example 'add incomplete activity' do
      expect do
        @feed42.add_activity({})
      end.to raise_error Stream::StreamApiResponseException
    end

    it 'should be able to follow many feeds in one request' do
      follows = [
        { source: 'flat:1', target: 'user:1' },
        { source: 'flat:1', target: 'user:3' }
      ]
      @client.follow_many(follows)
    end

    it 'should return an appropriate error if following many fails' do
      follows = [
        { source: 'badfeed:1', target: 'alsobad:1' },
        { source: 'extrabadfeed:1', target: 'reallybad:3' }
      ]
      url = @client.get_http_client.conn.url_prefix.to_s.gsub(%r{/+$}, '')
      expect do
        @client.follow_many(follows, 5000)
      end.to raise_error(
        Stream::StreamApiResponseException,
        %r{^POST #{url}/follow_many/\?activity_copy_limit=5000&api_key=[^:]+: 400: InputException details: activity_copy_limit must be a non-negative number not greater than 1000$}
      )
    end

    it 'should be able to unfollow many feeds in one request' do
      unfollows = [
        { source: 'user:1', target: 'timeline:1' },
        { source: 'user:2', target: 'timeline:2', keep_history: false }
      ]
      @client.unfollow_many(unfollows)
    end

    it 'should return an error if unfollowing many fails' do
      unfollows = [
        { source: 'user:1', target: 'timeline:1' },
        { source: 'user:2', target: 42, keep_history: false }
      ]
      url = @client.get_http_client.conn.url_prefix.to_s.gsub(%r{/+$}, '')
      expect do
        @client.unfollow_many(unfollows)
      end.to raise_error(
        Stream::StreamApiResponseException,
        %r{^POST #{url}/unfollow_many/\?api_key=[^:]+: 400: InputException details: invalid request payload$}
      )
    end

    it 'should be able to add one activity to many feeds in one request' do
      feeds = %w[flat:1 flat:2 flat:3 flat:4]
      activity_data = { actor: 'tommaso', verb: 'tweet', object: 1 }
      @client.add_to_many(activity_data, feeds)
    end

    example 'updating many feed activities' do
      activities = []
      (0..10).each do |i|
        activities << {
          actor: 'user:1',
          verb: 'do',
          object: "object:#{100 + i}",
          foreign_id: "object:#{100 + i}",
          time: DateTime.now
        }
        sleep 0.1
      end
      created_activities = @feed43.add_activities(activities)['activities']
      activities = Marshal.load(Marshal.dump(created_activities))

      sleep 1

      activities.each do |activity|
        activity.delete('id')
        activity['popularity'] = 100
      end

      @client.update_activities(activities)

      sleep 1

      updated_activities = @feed43.get(limit: activities.length)['results']
      updated_activities.sort_by! { |activity| activity['foreign_id'] }
      expect(updated_activities.count).to eql created_activities.count
      updated_activities.each_with_index do |activity, idx|
        expect(created_activities[idx]['foreign_id']).to eql activity['foreign_id']
        expect(created_activities[idx]['id']).to eql activity['id']
        expect(activity['popularity']).to eql 100
      end
    end

    describe 'collection CRUD endpoints' do
      before do
        @item_id = SecureRandom.uuid
      end
      example 'add object to collection' do
        response = @client.collections.add('animals', { type: 'bear', location: 'forest' })
        expect(response).to include('id', 'duration', 'collection', 'foreign_id', 'data', 'created_at', 'updated_at')
        expect(response['collection']).to eq 'animals'
        expect(response['data']).to eq 'type' => 'bear', 'location' => 'forest'
      end
      example 'add object to collection twice' do
        @client.collections.add('animals', { type: 'bear' }, id: @item_id)
        expect { @client.collections.add('animals', {}, id: @item_id) }.to raise_error Stream::StreamApiResponseException
      end
      example 'get collection item' do
        @client.collections.add('animals', { type: 'fox' }, id: @item_id)
        response = @client.collections.get('animals', @item_id)
        expect(response['id']).to eq @item_id
        expect(response['collection']).to eq 'animals'
        expect(response['foreign_id']).to eq "animals:#{@item_id}"
        expect(response['data']).to eq 'type' => 'fox'
      end
      example 'collection item update' do
        @client.collections.add('animals', { type: 'dog' }, id: @item_id)
        response = @client.collections.update('animals', @item_id, data: { type: 'cat' })
        expect(response['data']).to eq 'type' => 'cat'
      end
      example 'collection item delete' do
        @client.collections.add('animals', { type: 'snake' }, id: @item_id)
        @client.collections.delete('animals', @item_id)
        expect { @client.collections.get('animals', @item_id) }.to raise_error Stream::StreamApiResponseException
      end
    end

    example 'collections batch endpoints' do
      collections = @client.collections

      # refs
      expect(collections.create_reference('foo', 'bar')).to eql 'SO:foo:bar'

      # upsert
      objects = [
        {
          id: 'aabbcc',
          name: 'juniper',
          data: {
            hobbies: %w[playing sleeping eating]
          }
        },
        {
          id: 'ddeeff',
          name: 'ruby',
          data: {
            interests: ['sunbeams', 'surprise attacks']
          }
        }
      ]
      response = collections.upsert('test', objects)
      expect(response).to include('duration', 'data')
      expect(response['data']).to include 'test'
      expected = [
        {
          'data' => { 'hobbies' => %w[playing sleeping eating] },
          'id' => 'aabbcc',
          'name' => 'juniper'
        },
        {
          'data' => { 'interests' => ['sunbeams', 'surprise attacks'] },
          'id' => 'ddeeff',
          'name' => 'ruby'
        }
      ]
      expect(response['data']['test']).to eq(expected)

      # get
      response = collections.select('test', %w[aabbcc ddeeff])
      expect(response).to include('duration', 'response')
      expect(response['response']['data'].length).to eq 2
      expect(response['response']['data'][0]).to include('id', 'collection', 'foreign_id', 'data', 'created_at', 'updated_at')
      expected = [
        {
          'id' => 'aabbcc',
          'collection' => 'test',
          'foreign_id' => 'test:aabbcc',
          'data' => {
            'data' => {
              'hobbies' => %w[playing sleeping eating]
            },
            'id' => 'aabbcc',
            'name' => 'juniper'
          }
        },
        {
          'id' => 'ddeeff',
          'collection' => 'test',
          'foreign_id' => 'test:ddeeff',
          'data' => {
            'data' => {
              'interests' => ['sunbeams', 'surprise attacks']
            },
            'id' => 'ddeeff',
            'name' => 'ruby'
          }
        }
      ]
      check = response['response']['data']
      check.each do |h|
        h.delete('created_at')
        h.delete('updated_at')
      end
      expect(check).to eq(expected)

      # delete
      response = collections.delete_many('test', ['aabbcc'])
      expect(response).to include('duration')

      # check that the data is gone
      response = collections.select('test', %w[aabbcc ddeeff])
      expect(response).to include('duration', 'response')
      expected = [
        {
          'id' => 'ddeeff',
          'collection' => 'test',
          'foreign_id' => 'test:ddeeff',
          'data' => {
            'data' => {
              'interests' => ['sunbeams', 'surprise attacks']
            },
            'id' => 'ddeeff',
            'name' => 'ruby'
          }
        }
      ]
      check = response['response']['data']
      check.each do |h|
        h.delete('created_at')
        h.delete('updated_at')
      end
      expect(response['response']['data']).to eq(expected)
    end

    describe 'activities endpoints' do
      example 'get single activity' do
        activity = @feed42.add_activity({
                                          actor: 'bob',
                                          verb: 'does',
                                          object: 'something',
                                          foreign_id: "bob-does-stuff-#{Time.now.to_i}",
                                          time: DateTime.now.to_s
                                        })
        activity.delete('duration')

        expect { @client.get_activities }.to raise_error Stream::StreamApiResponseException

        # get by ID
        by_id = @client.get_activities(
          ids: [activity['id']]
        )
        expect(by_id).to include('duration', 'results')
        expect(by_id['results'].count).to be 1
        res = by_id['results'][0]
        res.delete('duration')
        expect(res).to eq(activity)

        # get by foreign_id/timestamp
        by_foreign_id = @client.get_activities(
          foreign_id_times: [
            { foreign_id: activity['foreign_id'], time: activity['time'] }
          ]
        )
        expect(by_foreign_id).to include('duration', 'results')
        expect(by_foreign_id['results'].count).to be 1
        res = by_foreign_id['results'][0]
        res.delete('duration')
        expect(res).to eq(activity)
      end

      example 'activity own reaction enrichment' do
        activity = @feed42.add_activity({ actor: 'jim', verb: 'buy', object: 'wallet' })
        reaction = @client.reactions.add('like', activity['id'], 'jim')
        reaction.delete('duration')

        response = @client.get_activities(ids: [activity['id']], reactions: { own: true })
        expect(response['results'][0]['own_reactions']['like'][0]).to eq reaction
      end
      example 'activity recent reaction enrichment' do
        activity = @feed42.add_activity({ actor: 'jim', verb: 'buy', object: 'wallet' })
        reaction = @client.reactions.add('dislike', activity['id'], 'jim')
        reaction.delete('duration')

        response = @client.get_activities(ids: [activity['id']], reactions: { recent: true })
        expect(response['results'][0]['latest_reactions']['dislike'][0]).to eq reaction
      end
      example 'activity reaction counts enrichment' do
        activity = @feed42.add_activity({ actor: 'jim', verb: 'buy', object: 'wallet' })
        @client.reactions.add('like', activity['id'], 'jim')

        response = @client.get_activities(ids: [activity['id']], reactions: { counts: true })
        expect(response['results'][0]['reaction_counts']['like']).to eq 1
      end
      example 'activity reaction kinds enrichment filtering' do
        activity = @feed42.add_activity({ actor: 'jim', verb: 'buy', object: 'wallet' })
        @client.reactions.add('like', activity['id'], 'jim')
        @client.reactions.add('comment', activity['id'], 'jim')

        response = @client.get_activities(ids: [activity['id']], reactions: { counts: true, kinds: ['like'] })
        expect(response['results'][0]['reaction_counts']['like']).to eq 1
        expect(response['results'][0]['reaction_counts']['comment']).to eq nil
      end

      example 'partial update' do
        activity_a = @feed42.add_activity({
                                            actor: 'bob',
                                            verb: 'does',
                                            object: 'something',
                                            foreign_id: "bob-does-stuff-#{Time.now.to_i}",
                                            time: DateTime.now.to_s,
                                            product: {
                                              name: 'shoes',
                                              price: 9.99,
                                              color: 'blue'
                                            }
                                          })
        activity_a.delete('duration')
        activity_b = @feed42.add_activity({
                                            actor: 'bob',
                                            verb: 'eats',
                                            object: 'nothing',
                                            foreign_id: "bob-eats-stuff-#{Time.now.to_i}",
                                            time: DateTime.now.to_s,
                                            product: {
                                              name: 'cheetos',
                                              price: 0.99,
                                              color: 'orange'
                                            },
                                            popularity: 42
                                          })
        activity_b.delete('duration')

        # by id
        updated_activity = @client.activity_partial_update(
          id: activity_a['id'],
          set: {
            'product.name': 'boots',
            'product.price': 7.99,
            popularity: 1000,
            foo: { bar: { baz: 'qux' } }
          },
          unset: [
            'product.color'
          ]
        )
        updated_activity.delete('duration')
        expected = activity_a
        expected['product'] = {
          'name' => 'boots',
          'price' => 7.99
        }
        expected['popularity'] = 1000
        expected['foo'] = {
          'bar' => {
            'baz' => 'qux'
          }
        }
        expect(updated_activity).to eq(expected)

        # by foreign id and timestamp
        updated_activity = @client.activity_partial_update(
          foreign_id: activity_a['foreign_id'],
          time: activity_a['time'],
          set: {
            'foo.bar.baz': 42,
            popularity: 9000
          },
          unset: [
            'product.price'
          ]
        )
        updated_activity.delete('duration')
        expected['product'] = {
          'name' => 'boots'
        }
        expected['foo'] = {
          'bar' => {
            'baz' => 42
          }
        }
        expected['popularity'] = 9000
        expect(updated_activity).to eq(expected)

        # in batch
        response = @client.batch_activity_partial_update([
                                                           {
                                                             id: activity_a['id'],
                                                             set: {
                                                               'product.name': 'boots',
                                                               'product.price': 13.99,
                                                               extra: 'left'
                                                             },
                                                             unset: ['foo']
                                                           },
                                                           {
                                                             id: activity_b['id'],
                                                             set: {
                                                               'product.price': 23.99,
                                                               extra: 'right'
                                                             },
                                                             unset: ['popularity']
                                                           }
                                                         ])
        expect(response['activities'].length).to eq 2
        activities = @client.get_activities(ids: [activity_a['id']])
        product = {
          'name' => 'boots',
          'price' => 13.99
        }
        expect(activities['results'][0]['product']).to eq product
        expect(activities['results'][0]['extra']).to eq 'left'
        expect(activities['results'][0]).not_to include('foo')
        activities = @client.get_activities(ids: [activity_b['id']])
        product = {
          'name' => 'cheetos',
          'color' => 'orange',
          'price' => 23.99
        }
        expect(activities['results'][0]['product']).to eq product
        expect(activities['results'][0]['extra']).to eq 'right'
        expect(activities['results'][0]).not_to include('popularity')

        response = @client.batch_activity_partial_update([
                                                           {
                                                             foreign_id: activity_a['foreign_id'],
                                                             time: activity_a['time'],
                                                             set: {
                                                               'product.name': 'trainers',
                                                               'product.price': 133.99
                                                             },
                                                             unset: ['extra']
                                                           },
                                                           {
                                                             foreign_id: activity_b['foreign_id'],
                                                             time: activity_b['time'],
                                                             set: {
                                                               'product.price': 3.99
                                                             },
                                                             unset: ['extra']
                                                           }
                                                         ])
        expect(response['activities'].length).to eq 2
        activities = @client.get_activities(ids: [activity_a['id']])
        product = {
          'name' => 'trainers',
          'price' => 133.99
        }
        expect(activities['results'][0]['product']).to eq product
        expect(activities['results'][0]).not_to include('extra')
        activities = @client.get_activities(ids: [activity_b['id']])
        product = {
          'name' => 'cheetos',
          'color' => 'orange',
          'price' => 3.99
        }
        expect(activities['results'][0]['product']).to eq product
        expect(activities['results'][0]).not_to include('extra')
      end
    end

    describe 'user endpoints' do
      before do
        @user_id = SecureRandom.uuid
      end
      example 'add user' do
        response = @client.users.add(@user_id, data: { animal: 'bear' })
        expect(response).to include('id', 'data', 'duration', 'created_at', 'updated_at')
        expect(response['id']).to eq @user_id
        expect(response['data']).to include 'animal'
        expect(response['data']['animal']).to eq 'bear'
      end
      example 'add user twice' do
        @client.users.add(@user_id)
        response = @client.users.add(@user_id, get_or_create: true)
        expect(response).to include('id', 'data', 'duration', 'created_at', 'updated_at')
      end
      example 'add user twice with error' do
        @client.users.add(@user_id)
        expect { @client.users.add(@user_id) }.to raise_error Stream::StreamApiResponseException
      end
      example 'get user' do
        create_response = @client.users.add(@user_id, data: { animal: 'wolf' })
        get_response = @client.users.get(@user_id)

        create_response.delete('duration')
        get_response.delete('duration')

        expect(get_response).to eq create_response
      end
      example 'update user' do
        @client.users.add(@user_id)
        response = @client.users.update(@user_id, data: { animal: 'dog' })
        expect(response).to include('id', 'data', 'duration', 'created_at', 'updated_at')
        expect(response['data']['animal']).to eq 'dog'
      end
      example 'delete user' do
        @client.users.add(@user_id)
        @client.users.delete(@user_id)
        expect { @client.users.get(@user_id) }.to raise_error Stream::StreamApiResponseException
      end
    end

    describe 'reaction endpoints' do
      before do
        @activity = @feed42.add_activity(actor: 'john', verb: 'tweet', object: 1)
      end
      example 'add reaction' do
        response = @client.reactions.add('like', @activity['id'], 'jim')
        expect(response).to include('id', 'kind', 'activity_id', 'user_id',
                                    'data', 'parent', 'latest_children',
                                    'children_counts', 'duration', 'created_at', 'updated_at')
        expect(response['activity_id']).to eq @activity['id']
        expect(response['user_id']).to eq 'jim'
        expect(response['kind']).to eq 'like'
      end
      example 'get reaction' do
        create_response = @client.reactions.add('like', @activity['id'], 'jim')
        response = @client.reactions.get(create_response['id'])
        expect(response).to include('id', 'kind', 'activity_id', 'user_id',
                                    'data', 'parent', 'latest_children',
                                    'children_counts', 'duration', 'created_at', 'updated_at')
        expect(response['activity_id']).to eq @activity['id']
        expect(response['user_id']).to eq 'jim'
        expect(response['kind']).to eq 'like'
        expect(response['data']).to eq({})
        expect(response['parent']).to eq ''
        expect(response['latest_children']).to eq({})
        expect(response['children_counts']).to eq({})
      end
      example 'update reaction' do
        create_response = @client.reactions.add('like', @activity['id'], 'jim')
        response = @client.reactions.update(create_response['id'], data: { animal: 'lion' })

        expect(response['data']['animal']).to eq 'lion'
      end
      example 'add child reaction' do
        create_response = @client.reactions.add('like', @activity['id'], 'jim')
        response = @client.reactions.add_child('dislike', create_response['id'], 'john')

        expect(response['parent']).to eq create_response['id']
      end
      example 'delete reaction' do
        reaction = @client.reactions.add('like', @activity['id'], 'jim')
        @client.reactions.delete(reaction['id'])
        expect { @client.reactions.get(reaction['id']) }.to raise_error Stream::StreamApiResponseException
      end
      example 'filter reactions' do
        parent = @client.reactions.add('like', @activity['id'], 'jim')
        child = @client.reactions.add_child('like', parent['id'], 'juan')
        comment = @client.reactions.add('comment', @activity['id'], 'jim')

        parent.delete('duration')
        child.delete('duration')
        comment.delete('duration')

        response = @client.reactions.filter(reaction_id: parent['id'])
        expect(response['results'][0]).to eq child

        response = @client.reactions.filter(user_id: 'jim', id_gt: parent['id'])
        expect(response['results'][0]).to eq comment

        response = @client.reactions.filter(kind: 'like', activity_id: @activity['id'], id_lte: child['id'])
        expect(response['results'].length).to eq 1
        expect(response['results'][0]['latest_children']['like'][0]).to eq child

        response = @client.reactions.filter(kind: 'comment', activity_id: @activity['id'])
        expect(response['results'][0]).to eq comment
      end
      example 'get with activity data' do
        @activity.delete('duration')
        @client.reactions.add('like', @activity['id'], 'jim')
        response = @client.reactions.filter(activity_id: @activity['id'], with_activity_data: true)

        response['activity'].delete('latest_reactions')
        response['activity'].delete('latest_reactions_extra')
        response['activity'].delete('own_reactions')
        response['activity'].delete('reaction_counts')
        expect(response['activity']).to eq @activity
      end
      example 'with target feeds' do
        reaction = @client.reactions.add('like', @activity['id'], 'juan', target_feeds: [@feed43.id], target_feeds_extra_data: { test: 'test_data' })
        reaction.delete('duration')
        response = @feed43.get

        expect(response['results'][0]['reaction']).to eq @client.reactions.create_reference(reaction)
        expect(response['results'][0]['verb']).to eq 'like'
        expect(response['results'][0]['test']).to eq 'test_data'
      end
    end

    describe 'feed enrichment' do
      example 'collection item enrichment' do
        bear = @client.collections.add('animals', { type: 'bear', color: 'blue' })
        bear.delete('duration')

        @feed42.add_activity({ actor: 'john', verb: 'chase', object: @client.collections.create_reference('animals', bear) })
        response = @feed42.get(enrich: true)
        expect(response['results'][0]['object']).to eq bear
      end
      example 'user enrichment' do
        user = @client.users.add(SecureRandom.uuid, data: { name: 'john' })
        user.delete('duration')

        @feed42.add_activity({ actor: @client.users.create_reference(user['id']), verb: 'chase', object: 'car:43' })
        response = @feed42.get(enrich: true)
        expect(response['results'][0]['actor']).to eq user
      end
      example 'own reaction enrichment' do
        activity = @feed42.add_activity({ actor: 'jim', verb: 'buy', object: 'wallet' })
        reaction = @client.reactions.add('like', activity['id'], 'jim')
        reaction.delete('duration')

        response = @feed42.get(reactions: { own: true })
        expect(response['results'][0]['own_reactions']['like'][0]).to eq reaction
      end
      example 'recent reaction enrichment' do
        activity = @feed42.add_activity({ actor: 'jim', verb: 'buy', object: 'wallet' })
        reaction = @client.reactions.add('dislike', activity['id'], 'jim')
        reaction.delete('duration')

        response = @feed42.get(reactions: { recent: true })
        expect(response['results'][0]['latest_reactions']['dislike'][0]).to eq reaction
      end
      example 'reaction counts enrichment' do
        activity = @feed42.add_activity({ actor: 'jim', verb: 'buy', object: 'wallet' })
        reaction = @client.reactions.add('like', activity['id'], 'jim')
        reaction.delete('duration')

        response = @feed42.get(reactions: { counts: true })
        expect(response['results'][0]['reaction_counts']['like']).to eq 1
      end
    end

    it 'get open graph' do
      response = @client.og('https://google.com')
      expect(response['title']).to be_truthy
      expect(response['description']).to be_truthy
    end
  end
end
