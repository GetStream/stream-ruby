require 'spec_helper'
require 'date'
require './spec/support/utils'

RSpec.configure do |c|
  c.include Utils
end

describe 'Integration tests' do
  before do
    @client = Stream::Client.new(ENV['STREAM_API_KEY'], ENV['STREAM_API_SECRET'], nil, location: ENV['STREAM_REGION'], default_timeout: 10)
    @feed42 = @client.feed('flat', generate_uniq_feed_name)
    @feed43 = @client.feed('flat', generate_uniq_feed_name)

    @test_activity = {:actor => 1, :verb => 'tweet', :object => 1}
  end

  context 'test client' do
    example 'posting an activity' do
      response = @feed42.add_activity(@test_activity)
      response.should include('id', 'actor', 'verb', 'object', 'target', 'time')
    end

    example 'posting many activities' do
      activities = [
          {:actor => 'tommaso', :verb => 'tweet', :object => 1},
          {:actor => 'thierry', :verb => 'tweet', :object => 1}
      ]
      actors = %w(tommaso thierry)
      @feed42.add_activities(activities)
      response = @feed42.get(:limit => 5)['results']
      [response[0]['actor'], response[1]['actor']].should =~ actors
    end

    example 'mark_seen=true should not mark read' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(:actor => 1, :verb => 'tweet', :object => 1)
      feed.add_activity(:actor => 2, :verb => 'share', :object => 1)
      feed.add_activity(:actor => 3, :verb => 'run', :object => 1)
      response = feed.get(:limit => 5)
      response['results'][0]['is_seen'].should eq false
      response['results'][1]['is_seen'].should eq false
      response['results'][2]['is_seen'].should eq false
      feed.get(:limit => 5, :mark_seen => true)
      response = feed.get(:limit => 5)
      response['results'][0]['is_seen'].should eq true #####
      response['results'][1]['is_seen'].should eq true #
      response['results'][2]['is_seen'].should eq true
      response['results'][0]['is_read'].should eq false
      response['results'][1]['is_read'].should eq false
      response['results'][2]['is_read'].should eq false
    end

    example 'mark_read=true should not mark seen' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(:actor => 1, :verb => 'tweet', :object => 1)
      feed.add_activity(:actor => 2, :verb => 'share', :object => 1)
      feed.add_activity(:actor => 3, :verb => 'run', :object => 1)
      response = feed.get(:limit => 5)
      response['results'][0]['is_read'].should eq false
      response['results'][1]['is_read'].should eq false
      response['results'][2]['is_read'].should eq false
      feed.get(:limit => 5, :mark_read => true)
      response = feed.get(:limit => 5)
      response['results'][0]['is_read'].should eq true ##
      response['results'][1]['is_read'].should eq true ###
      response['results'][2]['is_read'].should eq true
      response['results'][0]['is_seen'].should eq false
      response['results'][1]['is_seen'].should eq false
      response['results'][2]['is_seen'].should eq false
    end

    example 'set feed as read' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(:actor => 1, :verb => 'tweet', :object => 1)
      feed.add_activity(:actor => 2, :verb => 'share', :object => 1)
      feed.add_activity(:actor => 3, :verb => 'run', :object => 1)
      response = feed.get(:limit => 5)
      response['results'][0]['is_read'].should eq false
      response['results'][1]['is_read'].should eq false
      response['results'][2]['is_read'].should eq false #
      feed.get(:limit => 5, :mark_read => true)
      response = feed.get(:limit => 5)
      response['results'][0]['is_read'].should eq true #
      response['results'][1]['is_read'].should eq true
      response['results'][2]['is_read'].should eq true
    end

    example 'set activities as read' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(:actor => 1, :verb => 'tweet', :object => 1)
      feed.add_activity(:actor => 2, :verb => 'share', :object => 1)
      feed.add_activity(:actor => 3, :verb => 'run', :object => 1)
      response = feed.get(:limit => 2)
      ids = response['results'].collect {|a| a['id']}
      feed.get(:limit => 5, :mark_read => ids)
      response = feed.get(:limit => 5)
      response['results'][0]['is_read'].should eq true #
      response['results'][1]['is_read'].should eq true
      response['results'][2]['is_read'].should eq false #
    end

    example 'set feed as seen' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(:actor => 1, :verb => 'tweet', :object => 1)
      feed.add_activity(:actor => 2, :verb => 'share', :object => 1)
      feed.add_activity(:actor => 3, :verb => 'run', :object => 1)
      response = feed.get(:limit => 5)
      response['results'][0]['is_seen'].should eq false
      response['results'][1]['is_seen'].should eq false
      response['results'][2]['is_seen'].should eq false ##
      feed.get(:limit => 5, :mark_seen => true)
      response = feed.get(:limit => 5)
      response['results'][0]['is_seen'].should eq true
      response['results'][1]['is_seen'].should eq true
      response['results'][2]['is_seen'].should eq true
    end

    example 'set activities as seen' do
      feed = @client.feed('notification', generate_uniq_feed_name)
      feed.add_activity(:actor => 1, :verb => 'tweet', :object => 1)
      feed.add_activity(:actor => 2, :verb => 'share', :object => 1)
      feed.add_activity(:actor => 3, :verb => 'run', :object => 1)
      response = feed.get(:limit => 2)
      ids = response['results'].collect {|a| a['id']}
      feed.get(:limit => 5, :mark_seen => ids)
      response = feed.get(:limit => 5)
      response['results'][0]['is_seen'].should eq true
      response['results'][1]['is_seen'].should eq true
      response['results'][2]['is_seen'].should eq false
    end

    example 'posting an activity with datetime object' do
      feed = @client.feed('flat', generate_uniq_feed_name)
      activity = {:actor => 1, :verb => 'tweet', :object => 1, :time => DateTime.now}
      response = feed.add_activity(activity)
      response.should include('id', 'actor', 'verb', 'object', 'target', 'time')
    end

    example 'localised datetimes should be returned in UTC correctly' do
      feed = @client.feed('flat', generate_uniq_feed_name)
      now = DateTime.now.new_offset(5)
      activity = {:actor => 1, :verb => 'tweet', :object => 1, :time => now}
      response = feed.add_activity(activity)
      response.should include('id', 'actor', 'verb', 'object', 'target', 'time')
      response = feed.get(:limit => 5)
      DateTime.iso8601(response['results'][0]['time']).should be_within(1).of(now.new_offset(0))
    end

    example 'posting a custom field as a hash' do
      hash_value = {'a' => 42}
      activity = {:actor => 1, :verb => 'tweet', :object => 1, :hash_data => hash_value}
      response = @feed42.add_activity(activity)
      response.should include('id', 'actor', 'verb', 'object', 'target', 'hash_data')
      results = @feed42.get(:limit => 1)['results']
      results[0]['hash_data'].should eq hash_value
    end

    example 'posting a custom field as a list' do
      list_value = [1, 2, 3]
      activity = {:actor => 1, :verb => 'tweet', :object => 1, :hash_data => list_value}
      response = @feed42.add_activity(activity)
      response.should include('id', 'actor', 'verb', 'object', 'target', 'hash_data')
      results = @feed42.get(:limit => 1)['results']
      results[0]['hash_data'].should eq list_value
    end

    example 'posting and get one activity' do
      response = @feed42.add_activity(@test_activity)
      results = @feed42.get(:limit => 1)['results']
      results[0]['id'].should eq response['id']
    end

    example 'removing an activity' do
      feed = @client.feed('flat', generate_uniq_feed_name)
      response = feed.add_activity(@test_activity)
      results = feed.get(:limit => 1)['results']
      results[0]['id'].should eq response['id']
      feed.remove_activity(response['id'])
      results = feed.get(:limit => 1)['results']
      results[0]['id'].should_not eq response['id'] if results.count > 0
    end

    example 'removing an activity by foreign_id' do
      activity = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'ruby:42'}
      @feed42.add_activity(activity)
      activity = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'ruby:43'}
      @feed42.add_activity(activity)
      @feed42.remove_activity('ruby:43', foreign_id = true)
      results = @feed42.get(:limit => 2)['results']
      results[0]['foreign_id'].should eq 'ruby:42'
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
          results.length.should_not eq 0
        end
        example 'when a copy limit is given' do
          feed1 = @client.feed('flat', '1')
          feed2 = @client.feed('flat', generate_uniq_feed_name)
          feed1.add_activity(@test_activity)
          feed2.follow('flat', '1', 300)
          results = feed2.get['results']
          feed2.unfollow('flat', '1')
          results.length.should_not eq 0
        end
      end
      context 'should not copy an activity' do
        example 'when limit is set to 0' do
          feed1 = @client.feed('flat', '1')
          feed2 = @client.feed('flat', generate_uniq_feed_name)
          feed1.add_activity(@test_activity)
          feed2.follow('flat', '1', 0)
          results = feed2.get['results']
          results.length.should eq 0
          feed2.unfollow('flat', '1', false)
        end
      end
    end

    example 'retrieve feed with no followers' do
      lonely = @client.feed('flat', generate_uniq_feed_name)
      response = lonely.followers
      response['results'].should eq []
    end

    example 'retrieve feed followers with limit and offset' do
      @client.feed('flat', 'r43').follow('flat', 'r123')
      @client.feed('flat', 'r44').follow('flat', 'r123')
      response = @client.feed('flat', 'r123').followers
      response['results'][0]['feed_id'].should eq 'flat:r44'
      response['results'][0]['target_id'].should eq 'flat:r123'
      response['results'][1]['feed_id'].should eq 'flat:r43'
      response['results'][1]['target_id'].should eq 'flat:r123'
    end

    example 'retrieve feed with no followings' do
      asocial = @client.feed('flat', 'rasocial')
      response = asocial.following
      response['results'].should eq []
    end

    example 'retrieve feed followings with limit and offset' do
      social = @client.feed('flat', 'r2social')
      social.follow('flat', 'r43')
      social.follow('flat', 'r44')
      response = social.following(1, 1)
      response['results'][0]['feed_id'].should eq 'flat:r2social'
      response['results'][0]['target_id'].should eq 'flat:r43'
    end

    example 'i dont follow' do
      social = @client.feed('flat', 'rsocial1')
      response = social.following(0, 10, filter = ['flat:asocial'])
      response['results'].should eq []
    end

    example 'do i follow' do
      social = @client.feed('flat', 'rsocial2')
      social.follow('flat', 'r43')
      social.follow('flat', 'r244')
      response = social.following(0, 10, filter = ['flat:r244'])
      response['results'][0]['feed_id'].should eq 'flat:rsocial2'
      response['results'][0]['target_id'].should eq 'flat:r244'
      response = social.following(1, 10, filter = ['flat:r244'])
      response['results'].should eq []
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
      follower.get['results'][0]['id'].should eq response['id']
    end

    example 'posting activity using to' do
      recipient = 'flat', 'toruby11'
      activity = {
          :actor => 'tommaso', :verb => 'tweet', :object => 1, :to => [recipient.join(':')]
      }
      @feed42.add_activity(activity)
      target_feed = @client.feed(*recipient)
      response = target_feed.get(:limit => 5)['results']
      response[0]['actor'].should eq 'tommaso'
    end

    example 'posting many activities using to' do
      recipient = 'flat', 'toruby1'
      activities = [
          {:actor => 'tommaso', :verb => 'tweet', :object => 1, :to => [recipient.join(':')]},
          {:actor => 'thierry', :verb => 'tweet', :object => 1, :to => [recipient.join(':')]}
      ]
      actors = %w(tommaso thierry)
      @feed42.add_activities(activities)
      target_feed = @client.feed(*recipient)
      response = target_feed.get(:limit => 5)['results']
      [response[0]['actor'], response[1]['actor']].should =~ actors
    end

    example 'update to targets' do
      foreign_id = "user:1"
      time = DateTime.now
      activity = {
        :actor => 'tommaso',
        :verb => 'tweet',
        :object => 1,
        :to => ["user:1", "user:2"],
        :foreign_id => foreign_id,
        :time => time
      }
      @feed42.add_activity(activity)

      response = @feed42.update_activity_to_targets(
        foreign_id, time, new_targets: ["user:3", "user:2"]
      )
      response["activity"]["to"].length.should eq 2
      response["activity"]["to"].should include("user:2")
      response["activity"]["to"].should include("user:3")

      response = @feed42.update_activity_to_targets(
        foreign_id,
        time,
        added_targets: ["user:4", "user:5"],
        removed_targets: ["user:3"],
      )
      response["activity"]["to"].length.should eq 3
      response["activity"]["to"].should include("user:2")
      response["activity"]["to"].should include("user:4")
      response["activity"]["to"].should include("user:5")
    end

    example 'read from a feed' do
      @feed42.get
      @feed42.get(:limit => 5)
      @feed42.get(:offset => 4, :limit => 5)
    end

    example 'add incomplete activity' do
      expect do
        @feed42.add_activity({})
      end.to raise_error Stream::StreamApiResponseException
    end

    it 'should be able to follow many feeds in one request' do
      follows = [
        {:source => 'flat:1', :target => 'user:1'},
        {:source => 'flat:1', :target => 'user:3'}
      ]
      @client.follow_many(follows)
    end

    it 'should return an appropriate error if following many fails' do
      follows = [
        {:source => 'badfeed:1', :target => 'alsobad:1'},
        {:source => 'extrabadfeed:1', :target => 'reallybad:3'}
      ]
      url = @client.get_http_client.conn.url_prefix.to_s.gsub(/\/+$/, '')
      expect do
        @client.follow_many(follows, 5000)
      end.to raise_error(
        Stream::StreamApiResponseException,
        /^POST #{url}\/follow_many\/\?activity_copy_limit=5000&api_key=[^:]+: 400: InputException details: activity_copy_limit must be a non-negative number not greater than 1000$/
      )
    end

    it 'should be able to unfollow many feeds in one request' do
      unfollows = [
        {source: 'user:1', target: 'timeline:1'},
        {source: 'user:2', target: 'timeline:2', keep_history: false}
      ]
      @client.unfollow_many(unfollows)
    end

    it 'should return an error if unfollowing many fails' do
      unfollows = [
        {source: 'user:1', target: 'timeline:1'},
        {source: 'user:2', target: 42, keep_history: false}
      ]
      url = @client.get_http_client.conn.url_prefix.to_s.gsub(/\/+$/, '')
      expect do
        @client.unfollow_many(unfollows)
      end.to raise_error(
        Stream::StreamApiResponseException,
        /^POST #{url}\/unfollow_many\/\?api_key=[^:]+: 400: InputException details: invalid request payload$/
      )
    end

    it 'should be able to add one activity to many feeds in one request' do
      feeds = %w(flat:1 flat:2 flat:3 flat:4)
      activity_data = {:actor => 'tommaso', :verb => 'tweet', :object => 1}
      @client.add_to_many(activity_data, feeds)
    end

    example 'updating many feed activities' do
      activities = []
      (0..10).each do |i|
        activities << {
            actor: 'user:1',
            verb: 'do',
            object: "object:#{100+i}",
            foreign_id: "object:#{100+i}",
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
      updated_activities.sort_by!{|activity| activity['foreign_id']}
      expect(updated_activities.count).to eql created_activities.count
      updated_activities.each_with_index do |activity, idx|
        expect(created_activities[idx]['foreign_id']).to eql activity['foreign_id']
        expect(created_activities[idx]['id']).to eql activity['id']
        expect(activity['popularity']).to eql 100
      end
    end

    describe "collection CRUD endpoints" do
      before do
        @item_id = SecureRandom.uuid
      end
      example "add object to collection" do
        response = @client.collections.add("animals", {type: "bear", location: "forest"})
        response.should include("id", "duration", "collection", "foreign_id", "data", "created_at", "updated_at")
        response["collection"].should eq "animals"
        response["data"].should eq "type" => "bear", "location" => "forest"
      end
      example "add object to collection twice" do
        @client.collections.add("animals", {type: "bear"}, :id => @item_id)
        expect{@client.collections.add("animals", {}, :id => @item_id)}.to raise_error Stream::StreamApiResponseException
      end
      example "get collection item" do
        @client.collections.add("animals", {type: "fox"}, :id => @item_id)
        response = @client.collections.get("animals", @item_id)
        response["id"].should eq @item_id
        response["collection"].should eq "animals"
        response["foreign_id"].should eq "animals:#{@item_id}"
        response["data"].should eq "type" => "fox"
      end
      example "collection item update" do
        @client.collections.add("animals", {type: "dog"}, :id => @item_id)
        response = @client.collections.update("animals", @item_id, :data => {type: "cat"})
        response["data"].should eq "type" => "cat"
      end
      example "collection item delete" do
        @client.collections.add("animals", {type: "snake"}, :id => @item_id)
        @client.collections.delete("animals", @item_id)
        expect{@client.collections.get("animals", @item_id)}.to raise_error Stream::StreamApiResponseException
      end
    end

    example 'collections batch endpoints' do
      collections = @client.collections

      # refs
      collections.create_reference('foo', 'bar').should eql 'SO:foo:bar'

      # upsert
      objects = [
        {
          id: 'aabbcc',
          name: 'juniper',
          data: {
            hobbies: ['playing', 'sleeping', 'eating']
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
      response.should include('duration', 'data')
      response['data'].should include 'test'
      expected = [
        {
          'data' => { 'hobbies' => ['playing', 'sleeping', 'eating'] },
          'id' => 'aabbcc',
          'name' => 'juniper'
        },
        {
          'data' => { 'interests' => ['sunbeams', 'surprise attacks'] },
          'id' => 'ddeeff',
          'name' => 'ruby'
        }
      ]
      response['data']['test'].should =~ expected

      # get
      response = collections.select('test', ['aabbcc', 'ddeeff'])
      response.should include('duration', 'response')
      response['response']['data'].length.should eq 2
      response['response']['data'][0].should include('id', 'collection', 'foreign_id', 'data', 'created_at', 'updated_at')
      expected = [
        {
          'id' => 'aabbcc',
          'collection' => 'test',
          'foreign_id' => 'test:aabbcc',
          'data' => {
            'data' => {
              'hobbies' => ['playing', 'sleeping', 'eating']
            },
            'name' => 'juniper'
          },
        },
        {
          'id' => 'ddeeff',
          'collection' => 'test',
          'foreign_id' => 'test:ddeeff',
          'data' => {
            'data' => {
              'interests' => ['sunbeams', 'surprise attacks']
            },
            'name' => 'ruby'
          },
        }
      ]
      check = response['response']['data']
      check.each { |h| h.delete("created_at"); h.delete("updated_at") }
      check.should =~ expected

      # delete
      response = collections.delete_many('test', ['aabbcc'])
      response.should include('duration')

      # check that the data is gone
      response = collections.select('test', ['aabbcc', 'ddeeff'])
      response.should include('duration', 'response')
      expected = [
        {
          'id' => 'ddeeff',
          'collection' => 'test',
          'foreign_id' => 'test:ddeeff',
          'data' => {
            'data' => {
              'interests' => ['sunbeams', 'surprise attacks']
            },
            'name' => 'ruby'
          }
        }
      ]
      check = response['response']['data']
      check.each{ |h| h.delete("created_at"); h.delete("updated_at") }
      response['response']['data'].should =~ expected
    end

    describe 'activities endpoints' do
      example 'get single activity' do
        activity = @feed42.add_activity({
          actor: "bob",
          verb: "does",
          object: "something",
          foreign_id: "bob-does-stuff-#{Time.now.to_i}",
          time: DateTime.now.to_s,
        })
        activity.delete('duration')

        expect{@client.get_activities()}.to raise_error Stream::StreamApiResponseException

        # get by ID
        by_id = @client.get_activities(
          ids: [ activity["id"] ],
        )
        by_id.should include('duration', 'results')
        by_id['results'].count.should be 1
        res = by_id['results'][0]
        res.delete('duration')
        res.should eq(activity)

        # get by foreign_id/timestamp
        by_foreign_id = @client.get_activities(
          foreign_id_times: [
            { foreign_id: activity["foreign_id"], time: activity["time"] }
          ]
        )
        by_foreign_id.should include('duration', 'results')
        by_foreign_id['results'].count.should be 1
        res = by_foreign_id['results'][0]
        res.delete('duration')
        res.should eq(activity)
      end

      example 'partial update' do
        activity = @feed42.add_activity({
          actor: "bob",
          verb: "does",
          object: "something",
          foreign_id: "bob-does-stuff-#{Time.now.to_i}",
          time: DateTime.now.to_s,
          product: {
            name: "shoes",
            price: 9.99,
            color: "blue",
          }
        })
        activity.delete("duration")

        # by id
        updated_activity = @client.activity_partial_update(
          id: activity["id"],
          set: {
            "product.name": "boots",
            "product.price": 7.99,
            "popularity": 1000,
            "foo": {"bar": {"baz": "qux"}}
          },
          unset: [
            "product.color"
          ]
        )
        updated_activity.delete("duration")
        expected = activity
        expected["product"] = {
          "name" => "boots",
          "price" => 7.99,
        }
        expected["popularity"] = 1000
        expected["foo"] = {
          "bar" => {
            "baz" => "qux"
          }
        }
        updated_activity.should eq(expected)

        # by foreign id and timestamp
        updated_activity = @client.activity_partial_update(
          foreign_id: activity["foreign_id"],
          time: activity["time"],
          set: {
            "foo.bar.baz": 42,
            "popularity": 9000
          },
          unset: [
            "product.price"
          ]
        )
        updated_activity.delete("duration")
        expected["product"] = {
          "name" => "boots"
        }
        expected["foo"] = {
          "bar" => {
            "baz" => 42
          }
        }
        expected["popularity"] = 9000
        updated_activity.should eq(expected)
      end
    end

    describe "user endpoints" do
      before do
        @user_id = SecureRandom.uuid
      end
      example "add user" do
        response = @client.users.add(@user_id, :data => {animal: "bear"})
        response.should include("id", "data", "duration", "created_at", "updated_at")
        response["id"].should eq @user_id
        response["data"].should include "animal"
        response["data"]["animal"].should eq "bear"
      end
      example "add user twice" do
        @client.users.add(@user_id)
        response = @client.users.add(@user_id, :get_or_create => true)
        response.should include("id", "data", "duration", "created_at", "updated_at")
      end
      example "add user twice with error" do
        @client.users.add(@user_id)
        expect{@client.users.add(@user_id)}.to raise_error Stream::StreamApiResponseException
      end
      example "get user" do
        create_response = @client.users.add(@user_id, :data => {animal: "wolf"})
        get_response = @client.users.get(@user_id)

        create_response.delete("duration")
        get_response.delete("duration")

        get_response.should eq create_response
      end
      example "update user" do
        @client.users.add(@user_id)
        response = @client.users.update(@user_id, :data => {animal: "dog"})
        response.should include("id", "data", "duration", "created_at", "updated_at")
        response["data"]["animal"].should eq "dog"
      end
      example "delete user" do
        @client.users.add(@user_id)
        @client.users.delete(@user_id)
        expect{@client.users.get(@user_id)}.to raise_error Stream::StreamApiResponseException
      end
    end
  end
end
