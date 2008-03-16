require 'yaml'

module DepGraph
  class DependencyTypesManager
    def self.dependency_types_file
      File.join(File.dirname(__FILE__), 'dependency_types.yaml')
    end
    
    begin
      @@dependable_dependency_types = YAML.load_file(dependency_types_file)
    rescue => e
      fail "Could not load file #{dependency_types_file}: #{e.message}"
    end
      
    def self.types
      @@dependable_dependency_types.map {|type, _| type.to_sym}
    end
    
    def initialize(node_type = :anything)
      @node_type = node_type.to_s
    end
    
    def dependable_regexp
      get_node_type_parameters(@node_type)['dependable_regexp']
    end
        
    def dependable_regexp_capture_group_index
      get_node_type_parameters(@node_type)['capture_group_index']
    end
    
    def file_name_pattern
      get_node_type_parameters(@node_type)['file_name_pattern']
    end
    
    def get_node_type_parameters(node_type)
      node_type_parameters = @@dependable_dependency_types[node_type]
      
      if node_type_parameters
        return node_type_parameters
      else
        return default_parameters = {
          'dependable_regexp' => /.+/,
          'capture_group_index' => 0,
          'file_name_pattern' => '*'
        }
      end
    end
  end
end
