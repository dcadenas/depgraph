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

def create_graph_creator_with_two_nodes_and_one_orphan_dependency
  dependent1 = Dependent.new('file1.csproj')
  dependent2 = Dependent.new('file2.csproj')
  dependent2.depends_on('file3')
    
  graph_creator = GraphCreator.new(:none)    
  graph_creator.dependent_finder = MockDependentFinder.new([dependent1, dependent2])
  
  return graph_creator
end

def invalid_graph_creators
  {
    'graph creator with no dependents' => create_graph_creator_with_no_dependents,
    'graph creator with only one dependent' => create_graph_creator_with_only_one_dependent,
    'graph creator with three dependents that are equal' => create_graph_creator_with_three_dependents_that_are_equal,
    'graph creator with an orphan depencency' => create_graph_creator_with_two_nodes_and_one_orphan_dependency
  }
end

