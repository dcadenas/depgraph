require File.dirname(__FILE__) + "/../spec_helper"
require 'graph_image_creator'
require 'rubygems'
include FileTestHelper
include DepGraph

describe GraphImageCreator, '(integration tests)' do
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
  
  it 'can generate dot script'do
    graph = create_graph_with_2_nodes_and_1_edge
    with_files do
      graph.create_image('test.dot')
      File.exist?('test.dot').should be_true
      File.read('test.dot').match('digraph G').should_not be_nil
    end
  end
end

