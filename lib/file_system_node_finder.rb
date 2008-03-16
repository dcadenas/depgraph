require 'node'
require 'dependency_types_manager'

module DepGraph
  class FileSystemNodeFinder
    attr_accessor :dependable_filter, :dependable_filter_capture_group_index, :file_name_pattern
    attr_writer :dirs
    
    def initialize(node_type)
      
      dependable_filter_manager = DependencyTypesManager.new node_type
      @file_name_pattern = dependable_filter_manager.file_name_pattern
      @dependable_filter = dependable_filter_manager.dependable_regexp
      @dependable_filter_capture_group_index = dependable_filter_manager.dependable_regexp_capture_group_index
      @dirs = ['.']
    end 
    
    def dirs=(directories)
      @dirs = directories.map {|d| d.strip}
    end
    
    def get_nodes
      files = []
      @dirs.each do |dir|
        files += Dir.glob(dir.strip + '/**/' + @file_name_pattern)
      end
      
      nodes = []
      files.each { |file| nodes << create_node_from_file(file) }
      return nodes
    end
    
    def load_dependencies_from_string(node, dependencies_string)
      fail 'The dependable finder Regexp was not set' unless @dependable_filter

      dependencies_string.scan(@dependable_filter).each do |matches|
        dependable = (matches.respond_to? :to_ary) ? matches[@dependable_filter_capture_group_index] : matches
        node.depends_on(dependable) unless node.depends_on? dependable
      end
    end
    
    private
    def create_node_from_file file
      node = Node.new remove_extension(file)
      
      File.open(file) do |f|
        f.each_line do |line|
          load_dependencies_from_string(node, line)
        end
      end
      
      return node
    end
    
    def remove_extension file_path
      file_extension_regexp = /\.[^\.]+$/
      return File.basename(file_path).gsub(file_extension_regexp, '')
    end
  end
end