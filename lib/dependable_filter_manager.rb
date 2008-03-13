require 'yaml'

module DepGraph
  class DependableFilterManager
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
    
    def initialize(dependent_type = :anything)
      @dependent_type = dependent_type.to_s
    end
    
    def dependable_regexp
      get_dependent_type_parameters(@dependent_type)['dependable_regexp']
    end
        
    def dependable_regexp_capture_group_index
      get_dependent_type_parameters(@dependent_type)['capture_group_index']
    end
    
    def file_name_pattern
      get_dependent_type_parameters(@dependent_type)['file_name_pattern']
    end
    
    def get_dependent_type_parameters(dependent_type)
      dependent_type_parameters = @@dependable_dependency_types[dependent_type]
      
      if dependent_type_parameters
        return dependent_type_parameters
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
