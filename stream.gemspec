$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'stream/version'

Gem::Specification.new do |gem|
  gem.name = 'stream-ruby'
  gem.description = 'Ruby client for getstream.io service'
  gem.version = Stream::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.summary = 'A gem that provides a client interface for getstream.io'
  gem.email = 'support@getstream.io'
  gem.homepage = 'http://github.com/GetStream/stream-ruby'
  gem.authors = ['Tommaso Barbugli', 'Ian Douglas', 'Federico Ruggi']
  gem.extra_rdoc_files = %w[README.md LICENSE]
  gem.files = Dir['lib/**/*']
  gem.license = 'BSD-3-Clause'
  gem.required_ruby_version = '>=3.0.0'
  gem.metadata = {
    'rubygems_mfa_required' => 'false',
    'homepage_uri' => 'https://getstream.io/activity-feeds/',
    'bug_tracker_uri' => 'https://github.com/GetStream/stream-ruby/issues',
    'documentation_uri' => 'https://getstream.io/activity-feeds/docs/ruby/?language=ruby',
    'changelog_uri' => 'https://github.com/GetStream/stream-ruby/blob/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/GetStream/stream-ruby'
  }

  gem.add_dependency 'faraday'
  gem.add_dependency 'faraday-net_http_persistent'
  gem.add_dependency 'jwt'
  gem.add_dependency 'net-http-persistent'
end
