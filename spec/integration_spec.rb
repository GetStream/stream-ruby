require 'stream'

describe "Integration tests" do

    before do
        @client = Stream::Client.new('5crf3bhfzesn', 'tfq2sdqpj9g446sbv653x3aqmgn33hsn8uzdc9jpskaw8mj6vsnhzswuwptuj9su')
        @feed42 = @client.feed('flat:42')
        @test_activity = {:actor => 1, :verb => 'tweet', :object => 1}
    end

    context 'test client' do

        example "posting an activity" do
            response = @feed42.add_activity(@test_activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
        end

        example "posting and get one activity" do
            response = @feed42.add_activity(@test_activity)
            results = @feed42.get(:limit=>1)["results"]
            results[0]["id"].should eq response["id"]
        end

        example "removing an activity" do
            activity = @feed42.add_activity(@test_activity)
            @feed42.remove(activity["id"])
        end

        example "following a feed" do
            @feed42.follow('flat:43')
        end

        example "unfollowing a feed" do
            @feed42.follow('flat:43')
            @feed42.unfollow('flat:43')
        end

        example "read from a feed" do
            @feed42.get
            @feed42.get(:limit=>5)
            @feed42.get(:offset=> 4, :limit=>5)
            @feed42.get(:id_lt=> 14014774300137, :offset=> 4, :limit=>5)
        end

    end

end