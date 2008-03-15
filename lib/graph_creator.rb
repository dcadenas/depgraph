require 'rubygems'
require 'dependent'
require 'graph'
require 'file_system_dependent_finder'

module DepGraph
  class GraphCreator
    attr_writer :graph_class, :from, :to, :dependent_finder
    
    def initialize(dependent_type = :none)
      @dependent_finder = FileSystemDependentFinder.new(dependent_type)
      @graph_class = Graph
    end
    
    def dirs=(directories)
      @dependent_finder.dirs = directories
    end
    
    def excluded_nodes=(exc)
      @excluded_nodes = exc.map {|e| e.strip}
    end
    
    def create_image(image_file_name = 'dependency_graph.png')
      graph = create_graph
      
      if graph
        return graph.create_image(image_file_name) 
      else
        return false
      end
    end
    
    def create_graph
      nodes = @dependent_finder.get_dependents.uniq
      nodes = apply_filters(nodes)
      nodes = remove_disconnected_nodes(nodes)

      graph = @graph_class.new            
      return graph if nodes.size < 2


      nodes.each do |dependent|
        graph.add_node dependent
      end
      
      nodes.each do |dependent|
        dependent.dependencies.each do |dependable|
          graph.add_edge(dependent, dependable) if nodes.include? dependable
        end
      end
      
      return graph
    end

    private
    
    def remove_disconnected_nodes(nodes)
      nodes.select do |node|
        res = nodes.any? {|n| n.depends_on?(node) or node.depends_on?(n)}
        puts node.to_str unless res
        res
      end
    end
    
    def apply_filters(nodes)
      apply_exclude_filter apply_to_filter(apply_from_filter(nodes))
    end
    
    def apply_exclude_filter(nodes)
      return nodes unless @excluded_nodes
      
      regexps = Regexp.union(*@excluded_nodes)
      
      nodes.reject do |node|
        node.name.match(regexps)
      end
    end
    
    def apply_from_filter(nodes)
      return nodes unless @from
      
      nodes.select do |node|
        node.name.match(@from) or nodes.any?{|dependent| dependent.name.match(@from) and dependent.depends_on?(node)}
      end
    end
    
    def apply_to_filter(nodes)
      return nodes unless @to
      
      nodes.select do |node|
        node.name.match(@to) or nodes.any?{|dependable| node.depends_on?(dependable) and dependable.name.match(@to)}
      end
    end
  end
end