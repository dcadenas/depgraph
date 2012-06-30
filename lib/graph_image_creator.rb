require 'rubygems'
require 'graphviz'

module DepGraph
  class GraphImageCreator
    attr_writer :trans
    
    def initialize
      @nodes = []
      @edges = []
      @trans = false
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
          g = GraphViz::new( "G", :use => 'dot', :mode => 'major', :rankdir => 'LR', :concentrate => 'true', :fontname => 'Arial')      

          load_nodes(g, nodes)        
          load_edges(g, edges)

          create_output(g, image_file_name)          
          
          return true
        }
      end
    end
    
    def load_nodes(g, nodes)
      nodes.each do |node|
        g.add_nodes(quotify(node))
      end
    end
    
    def load_edges(g, edges)
      edges.each do |from, to|
        g.add_edges(quotify(from), quotify(to))
      end
    end
    
    def create_output(g, image_file_name)
      output_type = get_output_type(image_file_name)
          
      if @trans
        begin
          g.output(:dot => 'temp.dot')
          system "tred temp.dot|dot -T#{output_type} > #{image_file_name}"
        ensure
          File.delete('temp.dot')
        end
      else
        g.output(output_type => image_file_name)
      end
    end
    
    def get_output_type(image_file_name)
      #png is the default output type
      output_type = 'png'

      image_file_name.scan(/.+\.([^\.]*)$/) do |matches|
        output_type = matches[0]        
      end
      
      return output_type
    end
  end
end
