# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [6.0.0](https://github.com/GetStream/stream-ruby/compare/v5.1.0...v6.0.0) (2025-08-14)


### Bug Fixes

* multiple ID encoding for get_activities ([bbf666b](https://github.com/GetStream/stream-ruby/commit/bbf666b26acdcc4af618e77a59fa703b8910bd9a))

## [5.1.0](https://github.com/GetStream/stream-ruby/compare/v5.0.0...v5.1.0) (2023-11-20)


### Features

* soft delete and restore ([4c974be](https://github.com/GetStream/stream-ruby/commit/4c974be02f3b6897515c2d79d1843e03ddebd00c))

## [5.0.0](https://github.com/GetStream/stream-ruby/compare/v4.6.0...v5.0.0) (2023-03-31)


### Bug Fixes

* order of dependencies ([5d2b86b](https://github.com/GetStream/stream-ruby/commit/5d2b86bc6db2a5d6ff98858c628224bab17adb4f))
* remove redundant 'freeze' calls from regular expressions ([7b1c08a](https://github.com/GetStream/stream-ruby/commit/7b1c08a547d58d4927476507543f725e1497caa1))
* remove redundant development dependency declarations ([7f6239e](https://github.com/GetStream/stream-ruby/commit/7f6239e9ab76d9e8292ff3489d0e445c5a1bccf5))

## [4.6.0](https://github.com/GetStream/stream-ruby/compare/v4.5.0...v4.6.0) (2022-09-21)


### Features

* add follow stats endpoint ([#138](https://github.com/GetStream/stream-ruby/issues/138)) ([921981f](https://github.com/GetStream/stream-ruby/commit/921981fcb9cb4866a572a0281190bcd77a928319))
* specific exception classes for errors ([#142](https://github.com/GetStream/stream-ruby/issues/142)) ([ccf0b94](https://github.com/GetStream/stream-ruby/commit/ccf0b943eda21ad57c6d128402eba3aea4864731))


### Bug Fixes

* **rubocop:** ENV.fetch('xy') instead of ENV['xy'] per rubocop ([#140](https://github.com/GetStream/stream-ruby/issues/140)) ([6b25736](https://github.com/GetStream/stream-ruby/commit/6b25736b485daf63c9424abccfcfd20d7a993c50))

## 2022-01-26 - 4.5.0
* Add connection pooling into http client

## 2021-10-18 - 4.4.0
* Add first reaction support for feed read
* Add user id support in own reactions for reaction filtering

## 2021-09-27 - 4.3.0
* Add missing enrichment options to feed enrichment
* Add support to get activities enriched

## 2021-09-27 - 4.2.0
* Add feeds extra data support for reactions
* Repo maintenance improvements (i.e. README, CHANGELOG)

## 2021-03-15 - 4.1.0
- Add Ruby 3.x support

## 2021-03-15 - 4.0.2
- Fix delete activity call
- Move to github actions
- Handle rspec should deprecation
- Add envrc into gitignore

## 2021-01-05 - 4.0.1
- Relax versions on faraday/jwt dependencies

## 2020-11-18 - 4.0.0
- Update min Ruby version to 2.5 and add 2.7 into CI
- Add open graph scraper
- Setup rubocop for static code analysis
- Change signature of a couple of endpoints of feeds to modernize

```diff
- def remove_activity(activity_id, foreign_id = false)
+ def remove_activity(activity_id, foreign_id: false)

- def unfollow(target_feed_slug, target_user_id, keep_history = false)
+ def unfollow(target_feed_slug, target_user_id, keep_history: false)
```

## 2019-01-22 - 3.1.0
- Add support for batch activity partial update

## 2018-12-19 - 3.0.1
- Fix deleting reactions

## 2018-12-19 - 3.0.0
- Removed HTTP signatures based authentication
- Use JWT authentication for all endpoints
- Add support for users
- Add support for reactions
- Add support for enrichment of feeds

## 2018-10-30 - 2.11.1
- Add support for update-to-targets
- Fix tests

## 2018-10-30 - 2.11.0
- Added user session token create function
- Fix random test failures

## 2018-09-06 - 2.10.0
- Added collections ref helpers

## 2018-08-02 - 2.9.3
- Fixed a bug with add_activity causing alteration in the original activity.

## 2018-07-24 - 2.9.2
- Changed partial activity update endpoint method name to uniform with the other clients.

## 2018-07-12 - 2.9.1
- Changed default params format for single activity retrieval by foreign ID.

## 2018-07-11 - 2.9.0
- Added support for partial activity update endpoint.

## 2018-07-10 - 2.8.0
- Added support for get activities endpoint.

## 2018-06-29 - 2.7.1
- Relaxed jwt dependency.

## 2018-05-03 - 2.7.0
- Add support for unfollow many endpoint.

## 2018-04-26 - 2.6.1
- Fix client options defaults when nil values are provided.

## 2018-04-17 - 2.6.0
- Added support for personalization and collections endpoints.

## 2017-12-01 - 2.5.10
- Minor modification for Faraday middleware warning

## 2017-10-16 - 2.5.9
- updating core API hostname to our new .com domain
- added support to change the core hostname when instantiating the client (options[:api_hostame])

## 2017-09-21 - 2.5.8
- updating Ruby language version support on Travis-CI

## 2017-09-12 - 2.5.7

## 2017-06-09 - 2.5.6
- allowing versions of Faraday greater than v0.10 but less than 1.0

## 2017-05-23 - 2.5.5
- fixed bug with activity_copy_limit when a single feed follows another

## 2017-03-22 - 2.5.4
- fixed error messages when exceptions happen on response payloads (fixed from a bad 2.5.3 release)

## 2017-01-10 - 2.5.2
- fixed parameter ordering

## 2017-01-10 - 2.5.1
- customers reported non-empty GET bodies, which mess up auth signing

## 2016-12-19 - 2.5.0
- Switched from HTTParty to Faraday to allow more fine-grained control (more to come)

## 2016-12-09 - 2.4.5
- Removing persistence support while we evaluate other libraries to replace httparty

## 2016-10-15 - 2.4.4
- Added support in tests for Stream's new QA environment

## 2016-06-09 - 2.4.3
- Added support for keep_history on unfollow

## 2016-06-01 - 2.4.2
- Added support for activity_copy_limit on follow

## 2016-05-13 - 2.4.1
- Added update activity methods to client


## 2016-05-13 - 2.4.0
- Added support for update activity API

## 2016-03-15 - 2.3.1
- Bugfix release

## 2016-03-15 - 2.3.0
- Implement JWT authentication for all API calls
- Fix 1.9.3 support by using jwt 1.5.2
- Implement Stream::Feed#readonly_token
- add support for activity_copy_limit on follow_many

## 2016-01-22 - 2.2.5
- Better HTTP error message representation
- [bugfix] allow underscores for feed group labels

## 2016-01-08 - 2.2.4
- Code hygiene refactorings

## 2015-01-25 - 2.2.0
- Added support for add_to_many
- Added new request signing (using HTTP Signatures draft specification)
- Added code docs
- Added support for follow_many

## 2015-01-16 - 2.1.4
- Configurable API timeout

## 2014-12-18 - 2.1.0
- Configurable API location
- Configurable API version

## 2014-11-10 - 2.0.1
- Simplified syntax to create feeds, follow and unfollow feeds.
- Default HTTP timeout of 3s
- Better exception messages
- Add support for mark seen

## 2014-09-08 - 1.0.1
- Fix mark_read as boolean

## 2014-09-08 - 1.0.0
- Add support for mark read (notifications feeds)
