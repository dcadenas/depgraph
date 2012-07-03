require 'enumerator'
require 'file_test_helper'

dir = File.expand_path(File.dirname(__FILE__)) 
$LOAD_PATH.unshift("#{dir}/") 
$LOAD_PATH.unshift("#{dir}/../lib") 

require 'dependency_types_manager'
require 'graph_image_creator'
def dependency_types
  DepGraph::DependencyTypesManager.types
end

def non_empty_file_created(file_name)
  File.exist?(file_name) and File.size(file_name) > 0
end

def non_existent_filter_type
  DependencyTypesManager.types.join + 'thisdoesntexist'
end

########## Stubs ###########
class MockNodeFinder
  def initialize(nodes)
    @nodes = nodes
  end
    
  def get_nodes
    @nodes
  end
end
  
class NoOutputGraph < DepGraph::GraphImageCreator
  def initialize
    super
    output_generation = lambda { true }
  end
end

########## graph helper methods

def create_empty_graph
  GraphImageCreator.new
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
  lambda {|*args| true}
end

def dependency_exists?(graph, from, to)
  graph.has_node?(from) and graph.has_node?(to) and graph.has_edge?(from, to)
end


########## graph creator tests helper methods ###########
def create_graph_creator_with_no_nodes
  graph_creator = GraphCreator.new
  graph_creator.node_finder = MockNodeFinder.new([])
  
  return graph_creator
end

def create_graph_creator_with_only_one_node
  graph_creator = GraphCreator.new
  graph_creator.node_finder = MockNodeFinder.new([Node.new('node/path')])  
  
  return graph_creator
end

def create_2_connected_plus_2_disconnected_nodes_graph_creator
  node1 = Node.new('directory/path1')
  node2 = Node.new('directory/path2')
  node3 = Node.new('directory/anotherdir/path3')
  node4 = Node.new('directory2/path4')
  node5 = Node.new('directory2/anotherdir/path5')
  node1.depends_on(node2)
  node3.depends_on(node5)
  node4.depends_on(node5)
  
  graph_creator = GraphCreator.new    
  graph_creator.node_finder = MockNodeFinder.new([node1, node2, node3, node4])

  return graph_creator
end

def create_graph_creator_with_three_nodes_that_are_equal
  node1 = Node.new('directory/path')
  node2 = Node.new('directory/path')
  node3 = Node.new('directory/anotherdir/path')
    
  graph_creator = GraphCreator.new    
  graph_creator.node_finder = MockNodeFinder.new([node1, node2, node3])

  return graph_creator
end

def create_graph_creator_with_two_nodes_and_no_dependencies
  node1 = Node.new('node1/path1')
  node2 = Node.new('node2/path2')
    
  graph_creator = GraphCreator.new   
  graph_creator.node_finder = MockNodeFinder.new([node1, node2])

  return graph_creator
end

def create_dependency_chain_graph_creator(*node_names)
  nodes = []

  node_names.each do |node|
    nodes << Node.new(node)
  end

  nodes.each_cons(2) do |node, dependable|
    node.depends_on(dependable)
  end
    
  graph_creator = GraphCreator.new(:none)    
  graph_creator.node_finder = MockNodeFinder.new(nodes)
  
  return graph_creator
end

def create_graph_creator_with_two_nodes_and_one_dependency
  return create_dependency_chain_graph_creator('node1/path1.csproj', 'node2/path2.dll')
end

def create_2_node_graph_creator_with_1_normal_and_1_orphan_dependency
  node1 = Node.new('file1.csproj')
  node2 = Node.new('file2.csproj')
  node1.depends_on(node2)
  node2.depends_on('non existent file3')
    
  graph_creator = GraphCreator.new(:none)    
  graph_creator.node_finder = MockNodeFinder.new([node1, node2])
  
  return graph_creator
end

def create_2_connected_and_1_disconnected_node_with_an_orphan_dependency_graph_creator
  node1 = Node.new('file1.csproj')
  node2 = Node.new('file2.csproj')
  node3 = Node.new('file3.csproj')
  node4 = Node.new('file4.csproj')
  
  node1.depends_on(node2)
  
  #create an orphan dependency of disconnected node file3 because node4 will not be included in the graph
  node3.depends_on(node4) 
    
  graph_creator = GraphCreator.new(:none)    
  graph_creator.node_finder = MockNodeFinder.new([node1, node2, node3])
  
  return graph_creator
end

def invalid_graph_creators
  {
    'graph creator with no nodes' => create_graph_creator_with_no_nodes,
    'graph creator with only one node' => create_graph_creator_with_only_one_node,
    'graph creator with three nodes that are equal' => create_graph_creator_with_three_nodes_that_are_equal,
  }
end

