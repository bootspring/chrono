lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'timekeeper/version'

Gem::Specification.new do |s|
  s.name = %q{timekeeeper}
  s.version = Timekeeper::VERSION

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
     "timekeeper.gemspec",
  ]
  s.homepage = %q{http://github.com/mperham/timekeeper}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.test_files = Dir.glob("test/**/*")
  s.add_development_dependency(%q<shoulda>, [">= 0"])
  s.add_development_dependency(%q<mocha>, [">= 0"])
end

