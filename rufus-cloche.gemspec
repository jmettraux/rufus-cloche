
Gem::Specification.new do |s|

  s.name = 'rufus-cloche'
  s.version = '0.1.4'
  s.authors = [ 'John Mettraux' ]
  s.email = 'jmettraux@gmail.com'
  s.homepage = 'http://github.com/jmettraux/rufus-cloche/'
  s.platform = Gem::Platform::RUBY

  s.summary = 'a very stupid JSON hash store'

  s.description = %{
A very stupid JSON hash store.

It's built on top of yajl-ruby and File.lock. Defaults to 'json' (or 'json_pure') if yajl-ruby is not present (it's probably just a "gem install yajl-ruby" away.

Strives to be process-safe and thread-safe.
  }

  s.require_path = 'lib'
  s.test_file = 'test/test.rb'
  s.has_rdoc = false
  s.extra_rdoc_files = %w[ README.rdoc CHANGELOG.txt CREDITS.txt ]
  s.rubyforge_project = 'rufus'

  #%w{ ffi }.each do |d|
  #  s.requirements << d
  #  s.add_dependency(d)
  #end

  #s.files = Dir['lib/**/*.rb'] + Dir['*.txt'] - [ 'lib/tokyotyrant.rb' ]
  s.files = Dir['lib/**/*.rb'] + Dir['*.txt']
end

