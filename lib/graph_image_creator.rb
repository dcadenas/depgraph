require 'rubygems'
require 'graphviz'

module DepGraph
  class GraphImageCreator
    def initialize
      @nodes = []
      @edges = []
    end

    def node_count
      @nodes.size
    end
    
    def add_node(node_name)
      fail 'Node name not specified' if node_name.to_str.empty?
      @nodes << node_name.to_str
    end
    
    def has_node?(node_name)
      @nodes.include? node_name
    end

    def edge_count
      @edges.size
    end

    def add_edge(source_node_name, target_node_name)
      fail "Cannot create a dependency to the unregistered node #{target_node_name}" unless @nodes.include?(target_node_name.to_str)
      fail "Cannot create a dependency from the unregistered node #{source_node_name}" unless @nodes.include?(source_node_name.to_str) 
      
      @edges << [source_node_name.to_str, target_node_name.to_str]
    end
    
    def has_edge?(node1, node2)
      @edges.include? [node1, node2]
    end
    
    def reset
      @nodes.clear
      @edges.clear
    end
    
    def create_image(image_file_name)
      begin
        return false if @nodes.size == 0 or @edges.size == 0
        
        set_default_output_generation_unless_is_set
        
        return @output_generation.call(@nodes, @edges, image_file_name)
        
      rescue => e
        puts e.message
        puts e.backtrace
        return false
      end
    end
    
    def output_generation= output_generation_lambda
      @output_generation = output_generation_lambda
    end
    
    private
    def quotify(a_string)
      '"' + a_string + '"'
    end
    
    def set_default_output_generation_unless_is_set
      unless @output_generation 
        @output_generation = lambda {|nodes, edges, image_file_name|
          #TODO: Could we catch Graphviz errors that the wrapper couldn't catch?        
          g = GraphViz::new( "G", :use => 'dot', :mode => 'major', :rankdir => 'LR', :concentrate => 'true', :fontname => 'Arial', :file => image_file_name)      

        
          nodes.each do |node|
            g.add_node(quotify(node))
          end
      
          edges.each do |from, to|
            g.add_edge(quotify(from), quotify(to))
          end
      
          g.output( :output => "png")
          return true
        }
      end
    end
  end
end