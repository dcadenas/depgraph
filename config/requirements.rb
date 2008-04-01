require 'fileutils'
include FileUtils

require 'rubygems'
%w[rake hoe newgem rubigen filetesthelper spec optiflag graphviz rcov].each do |req_gem|
  begin
    require req_gem
  rescue LoadError
    req_gem = 'rspec' if req_gem == 'spec'
    req_gem = 'ruby-graphviz' if req_gem == 'graphviz'

    puts "This Rakefile requires the '#{req_gem}' RubyGem."
    puts "Installation: gem install #{req_gem} -y"
    exit
  end
end

$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

