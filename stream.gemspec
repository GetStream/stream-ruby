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
  gem.required_ruby_version = '>=2.5.0'
  gem.add_dependency 'faraday', ['>= 0.10.0', '< 1.0']
  gem.add_dependency 'jwt', ['>= 2.1.0', '~> 2.1']
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
end
