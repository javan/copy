# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "copy/version"

Gem::Specification.new do |s|
  s.name        = "copy"
  s.version     = Copy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Javan Makhmali"]
  s.email       = ["javan@javan.us"]
  s.homepage    = ""
  s.summary     = %q{Tiny CMS built on top of Sinatra}
  s.description = %q{Serve 'static' pages with blocks of client-editable text.}

  s.rubyforge_project = "copy"
  
  s.add_dependency "sinatra", "~> 1.2.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
