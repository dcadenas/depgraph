require File.dirname(__FILE__) + "/../spec_helper"
require 'file_system_node_finder'

include DepGraph

describe FileSystemNodeFinder do
  it 'should be able to get the dependencies to csproj and dll files from a string' do
    node_finder = FileSystemNodeFinder.new(:csproj)  
    node = Node.new('a')
    dependencies_string = 'from this string the dependable to "\\a.dir\\node1.csproj", \n"\\tgg.hyhy\\node2.dll" and "node3.csproj" should be found'
    
    node_finder.load_dependencies_from_string(node, dependencies_string)

    node.dependencies.should == ["node1", "node2", "node3"]
  end
  
  it 'should be able to use a custom regexp filter to get the node dependencies from a string' do
    node_finder = FileSystemNodeFinder.new(non_existent_filter_type)  
    dependencies_string = 'from this string the dependable to node.csproj \n and node1.dll should be found'
    node_finder.dependable_filter = /\s([^\s]+)\.(csproj|dll)[^\w]/
    node_finder.dependable_filter_capture_group_index = 0
    node = Node.new('a')
    
    node_finder.load_dependencies_from_string(node, dependencies_string)

    node.dependencies.should == ["node", "node1"]
  end
  
  it 'should be able to use a capture group in the dependable regexp filter' do
    node_finder = FileSystemNodeFinder.new(non_existent_filter_type)  
    dependencies_string = 'from this string the dependable to prefix.node.csproj \n and prefix.node1.dll should be found'
    node_finder.dependable_filter = /\s(prefix\.)([^\s]+)\.(csproj|dll)[^\w]/
    node_finder.dependable_filter_capture_group_index = 1 
    node = Node.new('a')
    
    node_finder.load_dependencies_from_string(node, dependencies_string)

    node.dependencies.should == ["node", "node1"]
  end
  
  it 'should ignore repeated dependencies in the string' do
    node_finder = FileSystemNodeFinder.new(:csproj)  
    node = Node.new('a')
    dependencies_string = 'this string has only one dependable that is repeated 3 times: "\\a.dir\\node.csproj", \n"\\tgg.hyhy\\node.dll" and "node.csproj"'
    
    node_finder.load_dependencies_from_string(node, dependencies_string)

    node.dependencies.should == ["node"]
  end
  
  it 'should ignore the capture group index if the dependable filter regexp has no capture groups' do
    node_finder = FileSystemNodeFinder.new(non_existent_filter_type)  
    node_finder.dependable_filter = /dep[0-9]/
    node_finder.dependable_filter_capture_group_index = 1 
    node = Node.new('a')
    
    node_finder.load_dependencies_from_string(node, 'dep1 is in the first line \n in the second dep2')
    
    node.dependencies.size.should == 2
  end
end

