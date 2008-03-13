require File.dirname(__FILE__) + "/spec_helper"
require 'graph'
require 'rubygems'
gem 'filetesthelper'
require 'spec'
require 'filetesthelper'
include FileTestHelper
include DepGraph

def create_empty_graph
  Graph.new
end

def create_graph_with_2_nodes_and_1_edge
  graph = create_empty_graph
  graph.add_node('node 1')
  graph.add_node('node 2')
  graph.add_edge('node 1', 'node 2')
  return graph
end

def create_graph_with_2_nodes_and_0_edges
  graph = create_empty_graph
  graph.add_node('node 1')
  graph.add_node('node 2')
  return graph
end

def no_output_generation
  lambda {true}
end

describe Graph do
  
  it "should start with no nodes" do
    create_empty_graph.node_count.should == 0
  end
  
  it "should be possible to add nodes" do
    graph = create_graph_with_2_nodes_and_0_edges
    
    graph.node_count.should == 2
    graph.edge_count.should == 0
  end
  
  it "should not be allowed to add a node without a name" do
    lambda {create_empty_graph.add_node('')}.should raise_error
  end
  
  it "should start with no edges" do
    create_empty_graph.edge_count.should == 0
  end
  
  it "should be possible to add an edge" do
    graph = create_graph_with_2_nodes_and_1_edge
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
  end
  
  it "can be reset" do
    graph = create_graph_with_2_nodes_and_1_edge
    
    graph.reset
    graph.node_count.should == 0
    graph.edge_count.should == 0
  end
    
  it "should not be allowed to add edges between non existent nodes" do
    lambda {create_empty_graph.add_edge('no node 1', 'no node 2')}.should raise_error
  end
  
  it "should return true when a new image file is created" do
    graph = create_graph_with_2_nodes_and_1_edge    
    graph.output_generation = no_output_generation
    graph.create_image('graph.png').should be_true
  end
  
  it "should return false when trying to create an empty graph" do
    graph = create_empty_graph
    graph.output_generation = no_output_generation
    graph.create_image('graph.png').should be_false
  end
end

describe Graph, '(integration tests)' do
  it "should create a file with the graph image" do
    with_files do
      graph = create_graph_with_2_nodes_and_1_edge    
      graph.create_image('graph.png')

      non_empty_file_created('graph.png').should be_true
    end
  end
  
  it "should not create an image file from an empty graph" do
    with_files do
      create_empty_graph.create_image('graph.png')
      non_empty_file_created('graph.png').should be_false
    end
  end
  
  it "should not create an image file from a graph with no edges" do
    with_files do
      create_graph_with_2_nodes_and_0_edges.create_image('graph.png')
      
      non_empty_file_created('graph.png').should be_false
    end
  end
  
  it 'can change output generation behaviour'do
    graph = create_graph_with_2_nodes_and_1_edge
    graph.output_generation = no_output_generation
    with_files do
      graph.create_image('test.png')
      File.exist?('test.png').should be_false
    end
  end
end

