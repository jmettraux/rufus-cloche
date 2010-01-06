# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rufus-cloche}
  s.version = "0.1.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mettraux"]
  s.date = %q{2010-01-06}
  s.description = %q{
A very stupid JSON hash store.

It's built on top of yajl-ruby and File.lock. Defaults to 'json' (or 'json_pure') if yajl-ruby is not present (it's probably just a "gem install yajl-ruby" away.

Strives to be process-safe and thread-safe.
  }
  s.email = %q{jmettraux@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
     "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.txt",
     "CREDITS.txt",
     "LICENSE.txt",
     "README.rdoc",
     "Rakefile",
     "TODO.txt",
     "lib/rufus-cloche.rb",
     "lib/rufus/cloche.rb",
     "rufus-cloche.gemspec",
     "test/bm/bm0.rb",
     "test/conc/put_vs_delete.rb",
     "test/ct_worker.rb",
     "test/ct_writer.rb",
     "test/test.rb"
  ]
  s.homepage = %q{http://github.com/jmettraux/rufus-cloche/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rufus}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{a very stupid JSON hash store}
  s.test_files = [
    "test/test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rufus-json>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<rufus-json>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<rufus-json>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

