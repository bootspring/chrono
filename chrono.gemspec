lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'chrono/version'

Gem::Specification.new do |s|
  s.name = %q{chrono}
  s.version = Chrono::VERSION

  s.authors = ["Mike Perham"]
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.description = s.summary = %q{Top secret}
  s.email = %q{mperham@gmail.com}
  s.files = Dir.glob("lib/**/*") + [
     "LICENSE",
     "README.md",
     "History.md",
     "Rakefile",
     "Gemfile",
     "chrono.gemspec",
  ]
  s.homepage = %q{http://github.com/mperham/chrono}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.test_files = Dir.glob("test/**/*")
  s.add_dependency 'faraday'
  s.add_dependency 'yajl-ruby'
  s.add_dependency 'typhoeus'
  s.add_dependency 'mongo'
  s.add_dependency 'bson_ext'
  s.add_dependency 'chronic'
  s.add_dependency 'rack-coffee'
  s.add_dependency 'redis'
  s.add_dependency 'sinatra'
  s.add_dependency 'i18n'
  s.add_dependency 'tzinfo'
  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_development_dependency 'rack-test'
end

