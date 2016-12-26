stream-ruby
===========

[![Build Status](https://travis-ci.org/GetStream/stream-ruby.svg?branch=master)](https://travis-ci.org/GetStream/stream-ruby) [![Gem Version](https://badge.fury.io/rb/stream-ruby.svg)](http://badge.fury.io/rb/stream-ruby)

stream-ruby is the official Ruby client for [Stream](https://getstream.io/), a web service for building scalable newsfeeds and activity streams.
The full documentation is available on [GetStream.io/docs/?language=ruby](http://getstream.io/docs/?language=ruby).
There is also a [higher level Rails integration](https://github.com/getstream/stream-rails) library which hooks into your ORM.

### Installation

```bash
gem install "stream-ruby"
```

### Usage

```ruby
# Instantiate a new client to connect to us east API endpoint
require 'stream'
client = Stream::Client.new('YOUR_API_KEY', 'API_KEY_SECRET', 'YOUR_APP_ID', :location => 'us-east')
# Find your API keys here https://getstream.io/dashboard/

# Instantiate a feed object
user_feed_1 = client.feed('user', '1')

# Get activities from 5 to 10 (slow pagination)
result = user_feed_1.get(:limit=>5, :offset=>5)
# (Recommended & faster) Filter on an id less than the given UUID
result = user_feed_1.get(:limit=>5, :id_lt=>'e561de8f-00f1-11e4-b400-0cc47a024be0')

# Create a new activity
activity_data = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'tweet:1'}
activity_response = user_feed_1.add_activity(activity_data)
# Create a bit more complex activity
activity_data = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'tweet:1',
	:course => {:name => 'Golden Gate park', :distance => 10},
	:participants => ['Thierry', 'Tommaso'],
	:started_at => DateTime.now()
}
activity_response = user_feed_1.add_activity(activity_data)

# Update an existing activity (requires both :foreign_id and :time fields)
activity_data = {:actor => 1, :verb => 'tweet', :object => 1, :foreign_id => 'tweet:1', :popularity => 100, :time => '2016-05-13T16:12:30'}
client.update_activity(activity_data)

# Update activities
client.update_activities([activity_data])

# Remove an activity by its id
user_feed_1.remove_activity('e561de8f-00f1-11e4-b400-0cc47a024be0')

# Remove activities by their foreign_id
user_feed_1.remove_activity('tweet:1', foreign_id=true)

# Follow another feed
user_feed_1.follow('flat', '42')

# Stop following another feed
user_feed_1.unfollow('flat', '42')

# Batch adding activities
activities = [
    [:actor => '1', :verb => 'tweet', :object => '1'],
    [:actor => '2', :verb => 'like', :object => '3']
]
user_feed_1.add_activities(activities)

# Batch following many feeds (requires ruby 2.1 or later)
follows = [{
    :source => 'flat:1', :target => 'user:1',
    :source => 'flat:1', :target => 'user:2',
    :source => 'flat:1', :target => 'user:3'
}]
client.follow_many(follows)

# Add an activity and push it to other feeds too using the `to` field
data = [
    :actor_id => "1",
    :verb => "like",
    :object_id => "3",
    :to => ["user:44", "user:45"]
]
user_feed_1.add_activity(data)

# Remove a feed and its content
user_feed_1.delete

# Generating tokens for client side usage
token = user_feed_1.readonly_token

# Javascript client side feed initialization
user1 = client.feed('user', '1', '{{ token }}');

# Retrieve first 10 followers of a feed
user_feed_1.followers(0, 10)

# Retrieve followers from 10 to 20
user_feed_1.followers(10, 10)

# Retrieve 10 feeds followed by user_feed_1
user_feed_1.following(10)

# Retrieve 10 feeds followed by user_feed_1 starting from the 11th
user_feed_1.following(10, 10)

# Check if user_feed_1 follows specific feeds
user_feed_1.following(0, 2, filter=['user:42', 'user:43'])

# Add one activity to many feeds in one request
feeds = ['flat:1', 'flat:2', 'flat:3', 'flat:4']
activity = {:actor => "User:2", :verb => "pin", :object => "Place:42", :target => "Board:1"}
client.add_to_many(activity, feeds)
```

Docs are available on [GetStream.io](http://getstream.io/docs/).
