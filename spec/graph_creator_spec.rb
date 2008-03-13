require File.dirname(__FILE__) + "/spec_helper"
require 'graph_creator'
require 'rubygems'
gem 'filetesthelper'
require 'spec'
require 'filetesthelper'
include DepGraph
include FileTestHelper
  
describe GraphCreator do
  it 'should not create a file if the graph is empty' do
    create_graph_creator_with_no_dependents.create_image.should be_false
  end

  it 'should return a nil graph if an empty set of dependents is specified' do
    create_graph_creator_with_no_dependents.create_graph.should == nil
  end
  
  it 'should return a nil graph if only one dependent is specified' do
    create_graph_creator_with_only_one_dependent.create_graph.should == nil
  end
  
  it 'should return a nil graph if all dependents specified are equal' do
    create_graph_creator_with_three_dependents_that_are_equal.create_graph.should == nil
  end
  
  it 'should return a graph with 2 nodes and no edges if 2 dependents with no dependencies are specified' do
    graph = create_graph_creator_with_two_dependents_and_no_dependencies.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 0
  end
  
  it 'should ignore dependencies to non existent dependents' do
    graph = create_graph_creator_with_two_nodes_and_one_orphan_dependency.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 0
  end
  
  it 'should return a graph with one edge if two dependents with one dependable are specified' do
    graph = create_graph_creator_with_two_nodes_and_one_dependency.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
  end
  
  it 'should be possible to filter dependents with a regular expression' do
    graph_creator = create_dependency_chain_graph_creator('node1', 'node2', 'node3', 'node4')
    graph_creator.from = 'e2$'
    graph = graph_creator.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
    graph.has_node?('node2').should be_true
    graph.has_node?('node3').should be_true
    graph.has_edge?('node2', 'node3').should be_true
  end
  
  it 'should be possible to filter dependables with a regular expression' do
    graph_creator = create_dependency_chain_graph_creator('node1', 'node2', 'node3', 'node4')
    graph_creator.to = 'e4$'
    graph = graph_creator.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
    graph.has_node?('node3').should be_true
    graph.has_node?('node4').should be_true
    graph.has_edge?('node3', 'node4').should be_true
  end

  
  invalid_graph_creators.each do |invalid_graph_creator_description, invalid_graph_creator|  
    it "should return false when trying to create an image from a #{invalid_graph_creator_description}" do
      invalid_graph_creator.graph_class = NoOutputGraph
      invalid_graph_creator.create_image('graph.png').should be_false
    end
  end
end

test_data = {
  :csproj => {'file1.csproj'=>'"file2.csproj"', 'dir/file2.csproj'=>'"file1.csproj"' },
  :ruby_requires => {'file1.rb'=>'require "file2"', 'dir/file2.rb'=>'require "file1"' }
}

describe GraphCreator, '(integration tests)' do
  dependency_types.each do |filter_type|
    it "should create a png image from the #{filter_type} dependencies found in the current directory tree" do
      with_files(test_data[filter_type]) do
        GraphCreator.new(filter_type).create_image('test.png')
      
        non_empty_file_created('test.png').should be_true
      end
    end
  end
end  







