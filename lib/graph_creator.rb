require 'rubygems'
require 'node'
require 'graph_image_creator'
require 'file_system_node_finder'

module DepGraph
  class GraphCreator
    attr_writer :graph_image_creator_class, :from, :to, :node_finder
    
    def initialize(node_type = :none)
      @node_finder = FileSystemNodeFinder.new(node_type)
      @graph_image_creator_class = GraphImageCreator
    end
    
    def dirs=(directories)
      @node_finder.dirs = directories
    end
    
    def excluded_nodes=(exc)
      @excluded_nodes = exc.map {|e| e.strip}
    end
    
    def create_image(image_file_name = 'dependency_graph.png')
      return create_graph.create_image(image_file_name) 
    end
    
    def create_graph
      nodes = @node_finder.get_nodes.uniq
      nodes = apply_filters(nodes)
      nodes = remove_disconnected_nodes(nodes)

      graph = @graph_image_creator_class.new            
      return graph if nodes.size < 2

      nodes.each do |node|
        graph.add_node(node)
      end
      
      nodes.each do |node|
        node.dependencies.each do |dependable|
          graph.add_edge(node, dependable) if nodes.include? dependable
        end
      end
      
      return graph
    end

    private
    
    def remove_disconnected_nodes(nodes)
      nodes.select do |node|
        nodes.any? {|n| n.depends_on?(node) or node.depends_on?(n)}
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
        node.name.match(@from) or nodes.any?{|n| n.name.match(@from) and n.depends_on?(node)}
      end
    end
    
    def apply_to_filter(nodes)
      return nodes unless @to
      
      nodes.select do |node|
        node.name.match(@to) or node.dependencies.any? {|d| d.name.match(@to)}
      end
    end
  end
end