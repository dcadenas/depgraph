require File.dirname(__FILE__) + "/../spec_helper"
require 'file_system_node_finder'
require 'rubygems'

include FileTestHelper
include DepGraph

describe FileSystemNodeFinder, '(integration tests)' do
  it 'should remove extensions from node names' do
    with_files('directory1/directory2/file.name.ext' => '') do
      node_finder = FileSystemNodeFinder.new(non_existent_filter_type)  
      node_finder.file_name_pattern = '*ext'
      nodes = node_finder.get_nodes
      nodes.should == ['file.name']
    end
  end

  it 'should search only in the specified directories' do
    with_files('good1/file1' => '', 'good2/file2' => '', 'bad/file3' => '') do
      node_finder = FileSystemNodeFinder.new(non_existent_filter_type)
      node_finder.location = ['good1', 'good2']
        
      nodes = node_finder.get_nodes
      nodes.should == ['file1', 'file2']
    end
  end
end

#To setup the test files for each filter type, include three sample node files
#and make the first file, named 'a' depend on the next two, named 'b' and 'c'
test_set = {
  :ruby_requires => {'a.rb' => 'require "b"\nrequire "c"', 'dir/b.rb' => '', 'dir/c.rb' => '', 'not_a_ruby_file' => ''},
  :csproj => {'a.csproj' => '"b.csproj"\n"c.csproj"', 'dir/b.csproj' => '', 'dir/c.csproj' => '', 'not_a_csproj_file' => ''}
}
  
dependency_types.each do |filter_type|
  test_files = test_set[filter_type]
  
  describe FileSystemNodeFinder, "for #{filter_type.to_s} (integration tests)" do
    it "should find the correct number of nodes" do
      with_files(test_files) do
        nodes = FileSystemNodeFinder.new(filter_type).get_nodes
        nodes.sort.should == ['a', 'b', 'c']
      end
    end
    it "should correctly find the dependencies from each file" do
      with_files(test_files) do
        node = FileSystemNodeFinder.new(filter_type).get_nodes.detect {|n| n.name == 'a'}
        node.should_not be_nil
        node.dependencies.should == ['b', 'c']
      end
    end
  end
end
