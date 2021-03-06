# coding: utf-8
# inspired by https://github.com/renzuinc/docker-tools 
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "docker/tasks/version"

Gem::Specification.new do |spec|
  spec.name          = "docker-tasks"
  spec.version       = Docker::Tasks::VERSION
  spec.authors       = ["Sree Pothula"]
  spec.summary       = "Common docker tasks for Rake and Docker CD pipeline."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"

  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "activesupport", "> 4.0"
  spec.add_runtime_dependency "foreman", "> 0"
  spec.add_runtime_dependency "bundler-audit", "> 0"
  spec.add_dependency 'rspec', '~> 3'
  spec.add_dependency 'rspec-its', '~> 1.2'
  spec.add_dependency 'inspec', '~> 0.32.0'
  spec.add_runtime_dependency "rubocop", "> 0"
  spec.add_runtime_dependency "pry", "> 0"
  spec.add_runtime_dependency "nokogiri", "> 0"
  spec.add_runtime_dependency "dotenv", "> 0"
end
