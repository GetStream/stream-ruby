require 'date'
require 'stream'


describe "Integration tests" do

    before do
        @client = Stream::Client.new('ahj2ndz7gsan', 'gthc2t9gh7pzq52f6cky8w4r4up9dr6rju9w3fjgmkv6cdvvav2ufe5fv7e2r9qy', nil, :location => 'us-east')
        @feed42 = @client.feed('flat', 'r42')
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

        example "mark_seen=true should not mark read" do
            feed = @client.feed('notification','rb1')
            feed.add_activity({:actor => 1, :verb => 'tweet', :object => 1})
            feed.add_activity({:actor => 2, :verb => 'share', :object => 1})
            feed.add_activity({:actor => 3, :verb => 'run', :object => 1})
            response = feed.get(:limit=>5)
            response["results"][0]["is_seen"].should eq false
            response["results"][1]["is_seen"].should eq false
            response["results"][2]["is_seen"].should eq false
            response = feed.get(:limit=>5, :mark_seen=>true)
            response = feed.get(:limit=>5)
            response["results"][0]["is_seen"].should eq true
            response["results"][1]["is_seen"].should eq true
            response["results"][2]["is_seen"].should eq true
            response["results"][0]["is_read"].should eq false
            response["results"][1]["is_read"].should eq false
            response["results"][2]["is_read"].should eq false
        end

        example "mark_read=true should not mark seen" do
            feed = @client.feed('notification', 'rb1')
            feed.add_activity({:actor => 1, :verb => 'tweet', :object => 1})
            feed.add_activity({:actor => 2, :verb => 'share', :object => 1})
            feed.add_activity({:actor => 3, :verb => 'run', :object => 1})
            response = feed.get(:limit=>5)
            response["results"][0]["is_read"].should eq false
            response["results"][1]["is_read"].should eq false
            response["results"][2]["is_read"].should eq false
            response = feed.get(:limit=>5, :mark_read=>true)
            response = feed.get(:limit=>5)
            response["results"][0]["is_read"].should eq true
            response["results"][1]["is_read"].should eq true
            response["results"][2]["is_read"].should eq true
            response["results"][0]["is_seen"].should eq false
            response["results"][1]["is_seen"].should eq false
            response["results"][2]["is_seen"].should eq false
        end

        example "set feed as read" do
            feed = @client.feed('notification', 'b1')
            feed.add_activity({:actor => 1, :verb => 'tweet', :object => 1})
            feed.add_activity({:actor => 2, :verb => 'share', :object => 1})
            feed.add_activity({:actor => 3, :verb => 'run', :object => 1})
            response = feed.get(:limit=>5)
            response["results"][0]["is_read"].should eq false
            response["results"][1]["is_read"].should eq false
            response["results"][2]["is_read"].should eq false
            response = feed.get(:limit=>5, :mark_read=>true)
            response = feed.get(:limit=>5)
            response["results"][0]["is_read"].should eq true
            response["results"][1]["is_read"].should eq true
            response["results"][2]["is_read"].should eq true
        end

        example "set activities as read" do
            feed = @client.feed('notification', 'rb2')
            feed.add_activity({:actor => 1, :verb => 'tweet', :object => 1})
            feed.add_activity({:actor => 2, :verb => 'share', :object => 1})
            feed.add_activity({:actor => 3, :verb => 'run', :object => 1})
            response = feed.get(:limit=>2)
            ids = response["results"].collect{|a| a['id']}
            response = feed.get(:limit=>5, :mark_read=>ids)
            response = feed.get(:limit=>5)
            response["results"][0]["is_read"].should eq true
            response["results"][1]["is_read"].should eq true
            response["results"][2]["is_read"].should eq false
        end

        example "set feed as seen" do
            feed = @client.feed('notification', 'rb3')
            feed.add_activity({:actor => 1, :verb => 'tweet', :object => 1})
            feed.add_activity({:actor => 2, :verb => 'share', :object => 1})
            feed.add_activity({:actor => 3, :verb => 'run', :object => 1})
            response = feed.get(:limit=>5)
            response["results"][0]["is_seen"].should eq false
            response["results"][1]["is_seen"].should eq false
            response["results"][2]["is_seen"].should eq false
            response = feed.get(:limit=>5, :mark_seen=>true)
            response = feed.get(:limit=>5)
            response["results"][0]["is_seen"].should eq true
            response["results"][1]["is_seen"].should eq true
            response["results"][2]["is_seen"].should eq true
        end

        example "set activities as seen" do
            feed = @client.feed('notification', 'rb4')
            feed.add_activity({:actor => 1, :verb => 'tweet', :object => 1})
            feed.add_activity({:actor => 2, :verb => 'share', :object => 1})
            feed.add_activity({:actor => 3, :verb => 'run', :object => 1})
            response = feed.get(:limit=>2)
            ids = response["results"].collect{|a| a['id']}
            response = feed.get(:limit=>5, :mark_seen=>ids)
            response = feed.get(:limit=>5)
            response["results"][0]["is_seen"].should eq true
            response["results"][1]["is_seen"].should eq true
            response["results"][2]["is_seen"].should eq false
        end

        example "posting an activity with datetime object" do
            feed = @client.feed('flat', 'time42')
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :time => DateTime.now}
            response = feed.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
        end

        example "localised datetimes should be returned in UTC correctly" do
            feed = @client.feed('flat', 'time43')
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
            feed = @client.feed('flat', 'removing_an_activity')
            response = feed.add_activity(@test_activity)
            results = feed.get(:limit=>1)["results"]
            results[0]["id"].should eq response["id"]
            feed.remove_activity(response["id"])
            results = feed.get(:limit=>1)["results"]
            if results.count > 0
                results[0]["id"].should_not eq response["id"]
            end
        end

        example "removing an activity by foreign_id" do
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'ruby:42'}
            activity = @feed42.add_activity(activity)
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'ruby:43'}
            activity = @feed42.add_activity(activity)
            @feed42.remove_activity('ruby:43', foreign_id=true)
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
            @feed42.follow('flat', '43')
        end

        example "retrieve feed with no followers" do
            lonely = @client.feed('flat', 'rlonely')
            response = lonely.followers()
            response['results'].should eq []
        end

        example "retrieve feed followers with limit and offset" do
            @client.feed('flat' ,'r43').follow('flat', 'r42')
            @client.feed('flat' ,'r44').follow('flat', 'r42')
            response = @feed42.followers()
            response['results'][0]['feed_id'].should eq 'flat:r44'
            response['results'][0]['target_id'].should eq 'flat:r42'
        end

        example "retrieve feed with no followings" do
            asocial = @client.feed('flat', 'rasocial')
            response = asocial.following()
            response['results'].should eq []
        end

        example "retrieve feed followings with limit and offset" do
            social = @client.feed('flat', 'r2social')
            social.follow('flat', 'r43')
            social.follow('flat', 'r44')
            response = social.following(1, 1)
            response['results'][0]['feed_id'].should eq 'flat:r2social'
            response['results'][0]['target_id'].should eq 'flat:r43'
        end

        example "i dont follow" do
            social = @client.feed('flat', 'rsocial1')
            response = social.following(0, 10, filter=['flat:asocial'])
            response['results'].should eq []
        end

        example "do i follow" do
            social = @client.feed('flat', 'rsocial2')
            social.follow('flat', 'r43')
            social.follow('flat', 'r244')
            response = social.following(0, 10, filter=['flat:r244'])
            response['results'][0]['feed_id'].should eq 'flat:rsocial2'
            response['results'][0]['target_id'].should eq 'flat:r244'
            response = social.following(1, 10, filter=['flat:r244'])
            response['results'].should eq []
        end

        example "following a private feed" do
            @feed42.follow('secret', '44')
        end

        example "unfollowing a feed" do
            @feed42.follow('flat', '43')
            @feed42.unfollow('flat', '43')
        end

        example "posting activity using to" do
            recipient = 'flat','toruby11'
            activity = {
                :actor => 'tommaso', :verb => 'tweet', :object => 1, :to => [recipient.join(':')]
            }
            @feed42.add_activity(activity)
            target_feed = @client.feed(*recipient)
            response = target_feed.get(:limit=>5)["results"]
            response[0]['actor'].should eq 'tommaso'
        end

        example "posting many activities using to" do
            recipient = 'flat','toruby1'
            activities = [
                {:actor => 'tommaso', :verb => 'tweet', :object => 1, :to => [recipient.join(':')]},
                {:actor => 'thierry', :verb => 'tweet', :object => 1, :to => [recipient.join(':')]},
            ]
            actors = ['tommaso', 'thierry']
            @feed42.add_activities(activities)
            target_feed = @client.feed(*recipient)
            response = target_feed.get(:limit=>5)["results"]
            [response[0]['actor'], response[1]['actor']].should =~ actors
        end

        example "read from a feed" do
            @feed42.get
            @feed42.get(:limit=>5)
            @feed42.get(:offset=> 4, :limit=>5)
        end

        example "add incomplete activity" do
            expect { 
                @feed42.add_activity(Hash.new)
            }.to raise_error Stream::StreamApiResponseException
        end

        it "should be able to send signed requests" do
            @client.make_signed_request('get', '/test/auth/digest/')
        end

        it "should be able to send signed requests with data" do
            @client.make_signed_request('post', '/test/auth/digest/', nil, :var=>[1, 2, '3'])
        end

        it "should be able to follow many feeds in one request" do
            follows = [
                {:source => 'flat:1', :target => 'user:1'},
                {:source => 'flat:1', :target => 'user:3'}
            ]
            @client.follow_many(follows)
        end

    end

end