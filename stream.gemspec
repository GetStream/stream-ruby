$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
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
  gem.has_rdoc = true
  gem.extra_rdoc_files = %w(README.md LICENSE)
  gem.files = Dir['lib/**/*']
  gem.license = 'BSD-3-Clause'
  gem.add_dependency 'faraday', ['>= 0.10.0', '< 1.0']
  gem.add_dependency 'http_signatures', '~> 0'
  gem.add_dependency 'jwt', ['>= 2.1.0', '~> 2.1']
  gem.add_development_dependency 'rake', '~> 0'
  gem.add_development_dependency 'rspec', '~> 2.10'
  gem.add_development_dependency 'simplecov', '~> 0.7'
end
