require 'enumerator'
begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

dir = File.expand_path(File.dirname(__FILE__)) 
$LOAD_PATH.unshift("#{dir}/") 
$LOAD_PATH.unshift("#{dir}/../lib") 

require 'dependable_filter_manager'
require 'graph'
def dependency_types
  DepGraph::DependableFilterManager.types
end

def non_empty_file_created(file_name)
  File.exist?(file_name) and File.size(file_name) > 0
end

def non_existent_filter_type
  DependableFilterManager.types.join + 'thisdoesntexist'
end

########## Stubs ###########
class MockDependentFinder
  def initialize(dependents)
    @dependents = dependents
  end
    
  def get_dependents
    @dependents
  end
end
  
class NoOutputGraph < DepGraph::Graph
  def initialize
    super
    output_generation = lambda { true }
  end
end

########## graph helper methods

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

def dependency_exists?(graph, from, to)
  graph.has_node?(from) and graph.has_node?(to) and graph.has_edge?(from, to)
end


########## graph creator tests helper methods ###########
def create_graph_creator_with_no_dependents
  graph_creator = GraphCreator.new
  graph_creator.dependent_finder = MockDependentFinder.new([])
  
  return graph_creator
end

def create_graph_creator_with_only_one_dependent
  graph_creator = GraphCreator.new
  graph_creator.dependent_finder = MockDependentFinder.new([Dependent.new('dependent/path')])  
  
  return graph_creator
end

def create_2_connected_plus_2_disconnected_nodes_graph_creator
  dependent1 = Dependent.new('directory/path1')
  dependent2 = Dependent.new('directory/path2')
  dependent3 = Dependent.new('directory/anotherdir/path3')
  dependent4 = Dependent.new('directory2/path4')
  dependent5 = Dependent.new('directory2/anotherdir/path5')
  dependent1.depends_on(dependent2)
  dependent3.depends_on(dependent5)
  dependent4.depends_on(dependent5)
  
  graph_creator = GraphCreator.new    
  graph_creator.dependent_finder = MockDependentFinder.new([dependent1, dependent2, dependent3, dependent4])

  return graph_creator
end

def create_graph_creator_with_three_dependents_that_are_equal
  dependent1 = Dependent.new('directory/path')
  dependent2 = Dependent.new('directory/path')
  dependent3 = Dependent.new('directory/anotherdir/path')
    
  graph_creator = GraphCreator.new    
  graph_creator.dependent_finder = MockDependentFinder.new([dependent1, dependent2, dependent3])

  return graph_creator
end

def create_graph_creator_with_two_dependents_and_no_dependencies
  dependent1 = Dependent.new('dependent1/path1')
  dependent2 = Dependent.new('dependent2/path2')
    
  graph_creator = GraphCreator.new   
  graph_creator.dependent_finder = MockDependentFinder.new([dependent1, dependent2])

  return graph_creator
end

def create_dependency_chain_graph_creator(*nodes)
  dependents = []

  nodes.each do |node|
    dependents << Dependent.new(node)
  end

  dependents.each_cons(2) do |dependent, dependable|
    dependent.depends_on(dependable)
  end
    
  graph_creator = GraphCreator.new(:none)    
  graph_creator.dependent_finder = MockDependentFinder.new(dependents)
  
  return graph_creator
end

def create_graph_creator_with_two_nodes_and_one_dependency
  return create_dependency_chain_graph_creator('dependent1/path1.csproj', 'dependent2/path2.dll')
end

def create_2_node_graph_creator_with_1_normal_and_1_orphan_dependency
  dependent1 = Dependent.new('file1.csproj')
  dependent2 = Dependent.new('file2.csproj')
  dependent1.depends_on(dependent2)
  dependent2.depends_on('non existent file3')
    
  graph_creator = GraphCreator.new(:none)    
  graph_creator.dependent_finder = MockDependentFinder.new([dependent1, dependent2])
  
  return graph_creator
end

def create_2_connected_and_1_disconnected_node_with_an_orphan_dependency_graph_creator
  dependent1 = Dependent.new('file1.csproj')
  dependent2 = Dependent.new('file2.csproj')
  dependent3 = Dependent.new('file3.csproj')
  dependent4 = Dependent.new('file4.csproj')
  
  dependent1.depends_on(dependent2)
  
  #create an orphan dependency of disconnected node file3 because dependent4 will not be included in the graph
  dependent3.depends_on(dependent4) 
    
  graph_creator = GraphCreator.new(:none)    
  graph_creator.dependent_finder = MockDependentFinder.new([dependent1, dependent2, dependent3])
  
  return graph_creator
end

def invalid_graph_creators
  {
    'graph creator with no dependents' => create_graph_creator_with_no_dependents,
    'graph creator with only one dependent' => create_graph_creator_with_only_one_dependent,
    'graph creator with three dependents that are equal' => create_graph_creator_with_three_dependents_that_are_equal,
  }
end

