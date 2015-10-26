$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'stream/version'

Gem::Specification.new do |gem|
  gem.name = "stream-ruby"
  gem.description = "Ruby client for getstream.io service"
  gem.version = Stream::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.summary = "A gem that provides a client interface for getstream.io"
  gem.email = "tbarbugli@gmail.com"
  gem.homepage = "http://github.com/GetStream/stream-ruby"
  gem.authors = ["Tommaso Barbugli"]
  gem.has_rdoc = true
  gem.extra_rdoc_files = ["README.md", "LICENSE"]
  gem.files = Dir['lib/**/*']
  gem.license = 'Apache-2.0'
  gem.add_dependency 'httparty', '~> 0'
  gem.add_dependency 'http_signatures', '~> 0'
  gem.add_development_dependency 'rake', '~> 0'
  gem.add_development_dependency 'rspec', '~> 2.10'
  gem.add_development_dependency 'simplecov', '~> 0.7'
end