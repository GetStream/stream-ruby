require 'date'
require 'stream'


describe "Integration tests" do

    before do
        @client = Stream::Client.new('ahj2ndz7gsan', 'gthc2t9gh7pzq52f6cky8w4r4up9dr6rju9w3fjgmkv6cdvvav2ufe5fv7e2r9qy')
        @feed42 = @client.feed('flat:r42')
        @test_activity = {:actor => 1, :verb => 'tweet', :object => 1}
    end

    context 'test client' do

        example "posting an activity" do
            response = @feed42.add_activity(@test_activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
        end

        example "posting many activities" do
            activities = [
                {:actor => 'tommaso', :verb => 'tweet', :object => 1},
                {:actor => 'thierry', :verb => 'tweet', :object => 1},
            ]
            actors = ['tommaso', 'thierry']
            @feed42.add_activities(activities)
            response = @feed42.get(:limit=>5)["results"]
            [response[0]['actor'], response[1]['actor']].should =~ actors
        end

        example "expose token from user feed" do
            @feed42.token.should match('.+')
        end

        example "posting an activity with datetime object" do
            feed = @client.feed('flat:time42')
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :time => DateTime.now}
            response = feed.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
        end

        example "localised datetimes should be returned in UTC correctly" do
            feed = @client.feed('flat:time43')
            now = DateTime.now.new_offset(5)
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :time => now}
            response = feed.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
            response = feed.get(:limit=>5)
            DateTime.iso8601(response["results"][0]["time"]).should be_within(1).of(now.new_offset(0))
        end

        example "posting a custom field as a hash" do
            hash_value = {'a' => 42}
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :hash_data => hash_value}
            response = @feed42.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "hash_data")
            results = @feed42.get(:limit=>1)["results"]
            results[0]["hash_data"].should eq hash_value
        end

        example "posting a custom field as a list" do
            list_value = [1,2,3]
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :hash_data => list_value}
            response = @feed42.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "hash_data")
            results = @feed42.get(:limit=>1)["results"]
            results[0]["hash_data"].should eq list_value
        end

        example "posting and get one activity" do
            response = @feed42.add_activity(@test_activity)
            results = @feed42.get(:limit=>1)["results"]
            results[0]["id"].should eq response["id"]
        end

        example "removing an activity" do
            response = @feed42.add_activity(@test_activity)
            results = @feed42.get(:limit=>1)["results"]
            results[0]["id"].should eq response["id"]
            @feed42.remove(response["id"])
            results = @feed42.get(:limit=>1)["results"]
            results[0]["id"].should_not eq response["id"]
        end

        example "removing an activity by foreign_id" do
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'ruby:42'}
            activity = @feed42.add_activity(activity)
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'ruby:43'}
            activity = @feed42.add_activity(activity)
            @feed42.remove('ruby:43', foreign_id=true)
            results = @feed42.get(:limit=>2)["results"]
            results[0]["foreign_id"].should eq 'ruby:42'
        end

        example "delete a feed" do
            response = @feed42.add_activity(@test_activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
            @feed42.delete
            response = @feed42.get
            response['results'].length.should eq 0
        end

        example "following a feed" do
            @feed42.follow('flat:43')
        end

        example "retrieve feed with no followers" do
            lonely = @client.feed('flat:lonely')
            response = lonely.followers()
            response['results'].should eq []
        end

        example "retrieve feed followers with limit and offset" do
            @client.feed('flat:43').follow('flat:42')
            @client.feed('flat:44').follow('flat:42')
            response = @feed42.followers(limit=1, offset=0)
            response['results'][0]['feed_id'].should eq 'flat:44'
            response['results'][0]['target_id'].should eq 'flat:42'
        end

        example "retrieve feed with no followings" do
            asocial = @client.feed('flat:asocial')
            response = asocial.following()
            response['results'].should eq []
        end

        example "retrieve feed followings with limit and offset" do
            social = @client.feed('flat:r2social')
            social.follow('flat:r43')
            social.follow('flat:r44')
            response = social.following(limit=1, offset=1)
            response['results'][0]['feed_id'].should eq 'flat:r2social'
            response['results'][0]['target_id'].should eq 'flat:r43'
        end

        example "i dont follow" do
            social = @client.feed('flat:social')
            response = social.following(limit=10, offset=0, filter=['flat:asocial'])
            response['results'].should eq []
        end

        example "do i follow" do
            social = @client.feed('flat:rsocial')
            social.follow('flat:r43')
            social.follow('flat:r244')
            response = social.following(limit=10, offset=1, filter=['flat:r244'])
            response['results'].should eq []
            response = social.following(limit=10, offset=0, filter=['flat:r244'])
            response['results'][0]['feed_id'].should eq 'flat:rsocial'
            response['results'][0]['target_id'].should eq 'flat:r244'
        end

        example "following a private feed" do
            @feed42.follow('secret:44')
        end

        example "unfollowing a feed" do
            @feed42.follow('flat:43')
            @feed42.unfollow('flat:43')
        end

        example "posting activity using to" do
            recipient = 'flat:toruby11'
            activity = {
                :actor => 'tommaso', :verb => 'tweet', :object => 1, :to => [recipient]
            }
            @feed42.add_activity(activity)
            target_feed = @client.feed(recipient)
            response = target_feed.get(:limit=>5)["results"]
            response[0]['actor'].should eq 'tommaso'
        end

        example "posting many activities using to" do
            recipient = 'flat:toruby1'
            activities = [
                {:actor => 'tommaso', :verb => 'tweet', :object => 1, :to => [recipient]},
                {:actor => 'thierry', :verb => 'tweet', :object => 1, :to => [recipient]},
            ]
            actors = ['tommaso', 'thierry']
            @feed42.add_activities(activities)
            target_feed = @client.feed(recipient)
            response = target_feed.get(:limit=>5)["results"]
            [response[0]['actor'], response[1]['actor']].should =~ actors
        end

        example "read from a feed" do
            @feed42.get
            @feed42.get(:limit=>5)
            @feed42.get(:offset=> 4, :limit=>5)
        end

    end

end