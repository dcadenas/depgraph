require 'node'

module DepGraph
  module NodeFinders
    
    #This is a simple example of a custom node finder with a hard coded graph.
    #Note that the file must be named [nodetype]_node_finder.rb containing a class named [Nodetype]NodeFinder
    #To use this example do: depgraph -type test
    class TestNodeFinder
      def location=(loc)
        #we will ignore location in this example
      end
      
      def get_nodes
        #let's return a hardcoded graph with 2 nodes and one dependency between them
        
        node1 = Node.new('node1')
        node2 = Node.new('node2')
        
        node1.depends_on(node2)
        
        return [node1, node2] 
      end
    end
  end
end
