# -*- encoding: utf-8 -*-

require File.expand_path("../lib/instagram/version", __FILE__)

Gem::Specification.new do |s|
  s.add_development_dependency("rake", "~> 11.2")
  s.add_development_dependency("rspec", "~> 3.4")
  s.add_development_dependency("webmock", "~> 1.22")
  s.add_development_dependency("bluecloth", "~> 2.2")
  s.add_development_dependency("rubocop")
  s.add_development_dependency("yard", "~> 0.9")

  s.add_runtime_dependency("faraday", "~> 0.11")
  s.add_runtime_dependency("faraday_middleware")
  s.add_runtime_dependency("multi_json")
  s.add_runtime_dependency("hashie", ">= 3.5.1")

  s.authors = ["Shayne Sweeney", "Nat Welch"]
  s.description = "A Ruby wrapper for the Instagram REST and Search APIs"
  s.email = ["shayne@instagr.am", "nat@natwelch.com"]
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.homepage = "https://github.com/icco/instagram-continued"
  s.name = "instagram-continued"
  s.platform = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6")
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubyforge_project = s.name
  s.summary = "Ruby wrapper for the Instagram API"
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Instagram::VERSION.dup
end
