require 'stream'

describe "Integration tests" do

    context 'init a test client' do

        before do
            @client = Stream::Client.new('5crf3bhfzesn', 'tfq2sdqpj9g446sbv653x3aqmgn33hsn8uzdc9jpskaw8mj6vsnhzswuwptuj9su')
            @feed42 = @client.feed('flat:42')
            @test_activity = {:actor => 1, :verb => 'tweet', :object => 1}
        end

        example "posting an activity" do
            @feed42.add_activity(@test_activity)
        end

        example "removing an activity" do
            activity = @feed42.add_activity(@test_activity)
            @feed42.remove(activity["id"])
        end

        example "following a fed" do
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
            @feed42.get(:lte=> 123, :offset=> 4, :limit=>5)
        end
    end

end