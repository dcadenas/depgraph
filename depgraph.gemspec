# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'lib/DepGraph/version.rb')

Gem::Specification.new do |s|
  s.name = "depgraph"
  s.summary = "A tool to create dependency graph images from source code directories"
  s.description =  "A tool to create dependency graph images from source code directories"
  s.email = "dcadenas@gmail.com"
  s.homepage = "http://github.com/dcadenas/depgraph"
  s.authors = ["Daniel Cadenas"]
  s.executables = ["depgraph"]

  s.add_dependency(%q<ruby-graphviz>, ["~> 1.0.8"])
  s.add_dependency(%q<optiflag>, [">= 0.6.5"])
  s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
  s.add_development_dependency(%q<rake>, ["~> 10.1.1"])
  s.add_development_dependency(%q<filetesthelper>, ["~> 1.0.1"])

  s.version = DepGraph::VERSION::STRING
  s.files = `git ls-files`.split
end

