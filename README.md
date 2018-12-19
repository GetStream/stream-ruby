stream-ruby
===========

[![Build Status](https://travis-ci.org/GetStream/stream-ruby.svg?branch=master)](https://travis-ci.org/GetStream/stream-ruby) [![Gem Version](https://badge.fury.io/rb/stream-ruby.svg)](http://badge.fury.io/rb/stream-ruby)

[stream-ruby](https://github.com/GetStream/stream-ruby) is the official Ruby client for [Stream](https://getstream.io/), a web service for building scalable newsfeeds and activity streams.

Note there is also a higher level [Ruby on Rails - Stream integration](https://github.com/getstream/stream-rails) library which hooks into the Ruby on Rails ORM.

You can sign up for a Stream account at https://getstream.io/get_started.

#### Ruby version requirements and support

This API Client project requires Ruby 2.2.10 at a minimum. We will support the following versions:
- 2.2.10
- 2.3.8
- 2.4.5
- 2.5.3

See the [Travis configuration](.travis.yml) for details of how it is built and tested.

### Installation

```bash
gem install "stream-ruby"
```

### Full documentation

Documentation for this Ruby client are available at the [Stream website](https://getstream.io/docs/ruby/?language=ruby).

### Usage

```ruby
# Instantiate a new client to connect to us east API endpoint
require 'stream'
client = Stream::Client.new('YOUR_API_KEY', 'API_KEY_SECRET', 'APP_ID', :location => 'us-east')
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
follows = [
  {:source => 'flat:1', :target => 'user:1'},
  {:source => 'flat:1', :target => 'user:2'},
  {:source => 'flat:1', :target => 'user:3'},
]
client.follow_many(follows)

# Add an activity and push it to other feeds too using the `to` field
data = [
    :actor_id => '1',
    :verb => 'like',
    :object_id => '3',
    :to => %w(user:44 user:45)
]
user_feed_1.add_activity(data)


# Updating parts of an activity
set = {
  'product.price': 19.99,
  'shares': {
    'facebook': '...',
    'twitter': '...'
  },
}
unset = [
    'daily_likes',
    'popularity'
]
# ...by ID
client.activity_partial_update(
  id: '54a60c1e-4ee3-494b-a1e3-50c06acb5ed4',
  set: set,
  unset: unset,
)
# ...or by combination of foreign ID and time
client.activity_partial_update(
  foreign_id: 'product:123',
  time: '2016-11-10T13:20:00.000000',
  set: set,
  unset: unset,
)

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
feeds = %w(flat:1 flat:2 flat:3 flat:4)
activity = {:actor => "User:2", :verb => "pin", :object => "Place:42", :target => "Board:1"}
client.add_to_many(activity, feeds)
```

### Copyright and License Information

Copyright (c) 2014-2018 Stream.io Inc, and individual contributors. All rights reserved.

See the file "LICENSE" for information on the history of this software, terms & conditions for usage, and a DISCLAIMER OF ALL WARRANTIES.
