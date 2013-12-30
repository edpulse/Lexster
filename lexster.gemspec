# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lexster/version"

Gem::Specification.new do |s|
  s.name        = "lexster"
  s.version     = Lexster::VERSION
  s.authors     = ["Nelson Wittwer, Elad Ossadon"]
  s.email       = ["nelsonwittwer@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Titan for ActiveRecord}
  s.description = %q{Extend Ruby on Rails ActiveRecord with Titan nodes. Keep RDBMS and utilize the power of Gremlin queries. Fork of Neoid.}

  s.rubyforge_project = "lexster"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rest-client'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'sqlite3'

  s.add_runtime_dependency 'neography'
end
