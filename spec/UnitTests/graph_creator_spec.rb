require File.dirname(__FILE__) + "/../spec_helper"
require 'graph_creator'
require 'rubygems'
include DepGraph
  
describe GraphCreator do
  it 'should not create a file if the graph is empty' do
    create_graph_creator_with_no_nodes.create_image.should be_false
  end

  it 'should return an empty graph if an empty set of nodes is specified' do
    graph = create_graph_creator_with_two_nodes_and_no_dependencies.create_graph
    
    graph.node_count.should == 0
    graph.edge_count.should == 0

  end
  
  it 'should return an empty graph if only one node is specified' do
    graph = create_graph_creator_with_two_nodes_and_no_dependencies.create_graph
    
    graph.node_count.should == 0
    graph.edge_count.should == 0

  end
  
  it 'should return an empty graph if all nodes specified are equal' do
    graph = create_graph_creator_with_two_nodes_and_no_dependencies.create_graph
    
    graph.node_count.should == 0
    graph.edge_count.should == 0

  end
  
  it 'should ignore disconnected nodes' do
    graph = create_2_connected_and_1_disconnected_node_with_an_orphan_dependency_graph_creator.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
  end
  
  it 'should ignore dependencies to non existent nodes' do
    graph = create_2_node_graph_creator_with_1_normal_and_1_orphan_dependency.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
  end
  
  it 'should return a graph with one edge if two nodes with one dependable are specified' do
    graph = create_graph_creator_with_two_nodes_and_one_dependency.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
  end
  
  it 'should be possible to filter dependent nodes with a regular expression' do
    graph_creator = create_dependency_chain_graph_creator('node1', 'node2', 'node3', 'node4')
    graph_creator.from = 'e2$'
    graph = graph_creator.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
    dependency_exists?(graph, 'node2', 'node3').should be_true
  end
  
  it 'should be possible to filter dependable nodes with a regular expression' do
    graph_creator = create_dependency_chain_graph_creator('node1', 'node2', 'node3', 'node4')
    graph_creator.to = 'e4$'
    graph = graph_creator.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
    dependency_exists?(graph, 'node3', 'node4').should be_true
  end
  
  it 'should exclude user selected nodes' do
    graph_creator = create_dependency_chain_graph_creator('node1', 'node2', 'anode3', 'node4isthisone')
    graph_creator.excluded_nodes = ['node3', 'node4', 'node6']
    graph = graph_creator.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
    dependency_exists?(graph, 'node1', 'node2').should be_true
  end
  
  it 'should not show disconnected nodes' do
    graph = create_2_connected_plus_2_disconnected_nodes_graph_creator.create_graph
    graph.node_count.should == 2
    graph.edge_count.should == 1
  end
  
  it 'should not show nodes that are only connected to excluded nodes' do
    graph_creator = create_dependency_chain_graph_creator('node1', 'node2', 'node3', 'node4')
    graph_creator.excluded_nodes = ['node3']
    graph = graph_creator.create_graph
    
    graph.node_count.should == 2
    graph.edge_count.should == 1
    dependency_exists?(graph, 'node1', 'node2').should be_true
  end
  
  it 'should notify sucessful image creation' do
    graph_creator = create_graph_creator_with_two_nodes_and_one_dependency
    graph_creator.graph_image_creator_class = NoOutputGraph
    graph_creator.create_image('graph.png').should be_true
  end
  
  it 'should notify failed image creation' do
    graph_creator = create_graph_creator_with_no_nodes
    graph_creator.graph_image_creator_class = NoOutputGraph
    graph_creator.create_image('graph.png').should be_false
  end
  
  it 'should dynamically load node finders based on the dependency type' do
    module DepGraph::NodeFinders
      class FakeNodeFinder
        def location=(d) end
        def get_nodes
          d1 = Node.new('node1')
          d2 = Node.new('node2')
          d1.depends_on(d2)
          [d1, d2]
        end
      end
    end
    
    graph = GraphCreator.new(:fake).create_graph

    graph.node_count.should == 2
    graph.edge_count.should == 1
    dependency_exists?(graph, 'node1', 'node2').should be_true
  end
  
  invalid_graph_creators.each do |invalid_graph_creator_description, invalid_graph_creator|  
    it "should return false when trying to create an image from a #{invalid_graph_creator_description}" do
      invalid_graph_creator.graph_image_creator_class = NoOutputGraph
      invalid_graph_creator.create_image('graph.png').should be_false
    end
  end
end
