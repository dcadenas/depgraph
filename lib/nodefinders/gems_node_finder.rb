require 'node'

module DepGraph
  module NodeFinders
    class GemsNodeFinder
      def initialize
        @spec_directories = Gem::Specification.dirs
      end

      def location=(loc)
        @spec_directories = loc
      end

      def get_nodes
        require 'rubygems'

        fail 'The gem specification directories were not set' unless @spec_directories and @spec_directories.size > 0

        nodes = {}
        @spec_directories.each do |spec_directory|
          Dir["#{spec_directory}/**/*.gemspec"].each do |gemspec_file_name|
            add_nodes_from_gemspec(nodes, gemspec_file_name)
          end
        end

        return nodes.values.sort
      end

      private
      def add_nodes_from_gemspec(nodes, gemspec_file_name)
        gem_dependencies = get_gemspec_dependencies(gemspec_file_name)
        gem_name = get_gemspec_name(gemspec_file_name)

        nodes[gem_name] ||= Node.new(gem_name)
        gem_dependencies.each do |gem_dependency|
          nodes[gem_dependency] ||= Node.new(gem_dependency)
          nodes[gem_name].depends_on(nodes[gem_dependency])
        end
      end

      def get_gemspec_dependencies(gemspec_file_name)
        gem_dependencies = []
        content = File.read(gemspec_file_name)
        content.scan(/add_dependency\(%q<([^>]+)>/) do |matches|
          matches.each do |match|
            gem_dependencies << match
          end
        end

        return gem_dependencies
      end

      def get_gemspec_name(gemspec_file_name)
        File.basename(gemspec_file_name).match(/(.+)-\d+/)[1].to_s
      end
    end
  end
end
