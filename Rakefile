
require 'rubygems'
require 'rake'


load 'lib/rufus/cloche.rb'


#
# CLEAN

require 'rake/clean'
CLEAN.include('pkg', 'tmp', 'html')
task :default => [ :clean ]


#
# GEM

require 'jeweler'

Jeweler::Tasks.new do |gem|

  gem.version = Rufus::Cloche::VERSION
  gem.name = 'rufus-cloche'
  gem.summary = 'a very stupid JSON hash store'
  gem.description = %{
A very stupid JSON hash store.

It's built on top of yajl-ruby and File.lock. Defaults to 'json' (or 'json_pure') if yajl-ruby is not present (it's probably just a "gem install yajl-ruby" away.

Strives to be process-safe and thread-safe.
  }
  gem.email = 'jmettraux@gmail.com'
  gem.homepage = 'http://github.com/jmettraux/rufus-cloche/'
  gem.authors = [ 'John Mettraux' ]
  gem.rubyforge_project = 'rufus'

  gem.test_file = 'test/test.rb'

  #gem.add_dependency 'yajl-ruby'
  #gem.add_dependency 'json'
  gem.add_dependency 'rufus-json'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'jeweler'

  # gemspec spec : http://www.rubygems.org/read/chapter/20
end
Jeweler::GemcutterTasks.new


#
# DOC

begin

  require 'yard'

  YARD::Rake::YardocTask.new do |doc|
    doc.options = [
      '-o', 'html/rufus-cloche', '--title',
      "rufus-cloche #{Rufus::Cloche::VERSION}"
    ]
  end

rescue LoadError

  task :yard do
    abort "YARD is not available : sudo gem install yard"
  end
end


#
# TO THE WEB

task :upload_website => [ :clean, :yard ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/rufus'

  sh "rsync -azv -e ssh html/rufus-cloche #{account}:#{webdir}/"
end

