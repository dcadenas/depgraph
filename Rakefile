require 'rubygems'
require 'rake'

spec = Gem::Specification.new do |s|
  s.name = "depgraph"
  s.summary = "A tool to create dependency graph images from source code directories"
  s.description =  "A tool to create dependency graph images from source code directories"
  s.email = "dcadenas@gmail.com"
  s.homepage = "http://github.com/dcadenas/depgraph"
  s.authors = ["Daniel Cadenas"]
  s.executables = ["depgraph"]

  s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
  s.add_dependency(%q<ruby-graphviz>, ["~> 1.0.8"])
  s.add_dependency(%q<optiflag>, [">= 0.6.5"])

  s.version = File.read("VERSION")
  s.files = `git ls-files`.split
end

require 'rake/extensiontask'
Gem::PackageTask.new(spec) do |pkg|
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec
