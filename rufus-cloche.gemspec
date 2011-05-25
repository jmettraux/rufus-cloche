# encoding: utf-8

require File.join(File.dirname(__FILE__), 'lib/rufus/cloche/version')
  # bundler wants absolute path


Gem::Specification.new do |s|

  s.name = 'rufus-cloche'
  s.version = Rufus::Cloche::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'http://ruote.rubyforge.org'
  s.rubyforge_project = 'rufus'
  s.summary = 'an open source Ruby workflow engine'
  s.description = %{
A very stupid JSON hash store.
  }
  s.description = %q{
A very stupid JSON hash store.

It's built on top of yajl-ruby and File.lock. Defaults to 'json' (or 'json_pure') if yajl-ruby is not present (it's probably just a "gem install yajl-ruby" away.

Strives to be process-safe and thread-safe.
  }

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Rakefile',
    'lib/**/*.rb', 'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'rufus-json', '>= 0.2.7'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'json'

  s.require_path = 'lib'
end

