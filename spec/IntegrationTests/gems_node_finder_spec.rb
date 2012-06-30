require File.dirname(__FILE__) + "/../spec_helper"
require 'rubygems'
require 'nodefinders/gems_node_finder'

include FileTestHelper
include DepGraph::NodeFinders

describe GemsNodeFinder do
  it "should list all gems and its dependencies" do
    with_files('fakegem-0.9.1.gemspec' => 's.add_dependency(%q<fakedependencygem>, [">= 1.5.0"])') do
      gems_node_finder = GemsNodeFinder.new
      gems_node_finder.location = ['./']
      nodes = gems_node_finder.get_nodes
    
      nodes.should == ['fakedependencygem', 'fakegem']
      nodes[1].dependencies.size.should == 1
      nodes[1].dependencies[0].name.should == 'fakedependencygem'
    end
  end
end
