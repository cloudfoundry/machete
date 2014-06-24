# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'machete/version'

Gem::Specification.new do |spec|
  spec.name          = "machete"
  spec.version       = Machete::VERSION
  spec.authors       = ["Jordi Noguera and Rasheed Abdul-Aziz and Aaron Triantafyllidis"]
  spec.email         = ["pair+jordi+squeedee@pivotallabs.com"]
  spec.summary       = %q{Machete is the offline buildpack library for Cloud Foundry Buildpacks}
  spec.description   = %q{Machete is the offline buildpack library for Cloud Foundry Buildpacks}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'rspec'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'httparty'
end
