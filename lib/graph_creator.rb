require 'rubygems'
require 'dependent'
require 'graph'
require 'file_system_dependent_finder'

module DepGraph
  class GraphCreator
    attr_accessor :dependent_finder 
    
    def initialize(dependent_type = :none)
      @dependent_finder = FileSystemDependentFinder.new(dependent_type)
      @graph_class = Graph
    end
    
    def graph_class= the_graph_class
      @graph_class = the_graph_class
    end
    
    def dirs=(directories)
      @dependent_finder.dirs = directories
    end
    
    def from=(from_filter)
      @from_filter = from_filter
    end
    
    def to=(to_filter)
      @to_filter = to_filter
    end

    
    def create_graph
      nodes = @dependent_finder.get_dependents.uniq
      return nil if nodes.size < 2
      
      dependents = apply_from_filter(nodes)
      dependents = apply_to_filter(dependents)
      
      graph = @graph_class.new
      
      dependents.each do |dependent|
        graph.add_node dependent
      end
      
      dependents.each do |dependent|
        dependent.dependencies.each do |dependable|
          graph.add_edge(dependent, dependable) if dependents.include? dependable
        end
      end
      
      return graph
    end
    
    def apply_from_filter(nodes)
      return nodes unless @from_filter
      
      selected_dependents = nodes.select do |node|
        node.name.match(@from_filter) or nodes.any?{|dependent| dependent.name.match(@from_filter) and dependent.depends_on?(node)}
      end
      
      return selected_dependents
    end
    
    def apply_to_filter(nodes)
      return nodes unless @to_filter
      
      selected_dependents = nodes.select do |node|
        node.name.match(@to_filter) or nodes.any?{|dependable| node.depends_on?(dependable) and dependable.name.match(@to_filter)}
      end
      
      return selected_dependents
    end

    
    def create_image(image_file_name = 'dependency_graph.png')
      graph = create_graph
      
      if graph
        return graph.create_image(image_file_name) 
      else
        return false
      end
    end
  end
end