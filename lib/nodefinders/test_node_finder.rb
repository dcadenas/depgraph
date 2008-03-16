require 'node'

module DepGraph
  module NodeFinders
    
    #This is an example of a custom node finder with a hard coded graph from node1 to node2.
    class TestNodeFinder
      def dirs=(d) end
      def get_nodes
        d1 = Node.new('node1')
        d2 = Node.new('node2')
        d1.depends_on(d2)
        [d1, d2]
      end
    end
  end
end