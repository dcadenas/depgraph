module DepGraph

  #A Dependent knows its dependables and knows how to get them from a string
  class Dependent
    include Comparable
    attr_reader :name

    def initialize(dependent_uri, dependent_type = :anything)
      fail 'Empty uris are not allowed' if dependent_uri.empty?
      @name = remove_extension dependent_uri
      @dependencies = []

      load_filter_type(dependent_type)
    end
    
    def load_filter_type(dependent_type)
      dependable_filter_manager = DependableFilterManager.new dependent_type
      @dependable_filter = dependable_filter_manager.dependable_regexp
      @dependable_filter_capture_group_index = dependable_filter_manager.dependable_regexp_capture_group_index
    end
    
    def to_str
      @name
    end
    
    def <=> other_dependent
      @name <=> other_dependent.to_str
    end
    
    def eql? other_dependent
      (self <=> other_dependent) == 0
    end
    
    def hash
      @name.hash
    end
    
    def remove_extension file_path
      file_extension_regexp = /\.[^\.]+$/
      return File.basename(file_path).gsub(file_extension_regexp, '')
    end
    
    def depends_on dependent
      @dependencies << dependent
    end
    
    def depends_on? dependent
      @dependencies.include? dependent
    end

    def dependencies
      @dependencies
    end
    
    def dependable_filter= filter
      @dependable_filter = filter
      @dependable_filter_capture_group_index = 0
    end
    
    def dependable_filter_capture_group_index= group_index
      @dependable_filter_capture_group_index = group_index
    end
    
    def load_dependencies_from_string(dependencies_string)
      fail 'The dependable finder Regexp was not set' unless @dependable_filter

      dependencies_string.scan(@dependable_filter).each do |matches|
        dependable = (matches.respond_to? :to_ary) ? matches[@dependable_filter_capture_group_index] : matches
        depends_on(dependable) unless depends_on? dependable
      end
    end
  end
end