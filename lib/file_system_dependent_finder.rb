require 'dependent'
require 'dependable_filter_manager'

module DepGraph
  class FileSystemDependentFinder
    attr_reader :dependent_filter, :dependable_filter, :dependable_filter_capture_group_index
    attr_writer :dirs
    
    def initialize(dependent_type)
      
      dependable_filter_manager = DependableFilterManager.new dependent_type
      @file_name_pattern = dependable_filter_manager.file_name_pattern
      @dependable_filter = dependable_filter_manager.dependable_regexp
      @dependable_filter_capture_group_index = dependable_filter_manager.dependable_regexp_capture_group_index
      @dirs = ['.']
    end 
    
    def dirs=(directories)
      @dirs = directories.map {|d| d.strip}
    end
    
    def get_dependents
      files = []
      @dirs.each do |dir|
        files += Dir.glob(dir.strip + '/**/' + @file_name_pattern)
      end
      
      dependents = []
      files.each { |file| dependents << create_dependent_from_file(file) }
      return dependents
    end
    
    private
    def create_dependent_from_file file
      dependent = Dependent.new file
      dependent.dependable_filter = @dependable_filter
      dependent.dependable_filter_capture_group_index = @dependable_filter_capture_group_index 
      
      File.open(file) do |f|
        f.each_line do |line|
          dependent.load_dependencies_from_string(line)
        end
      end
      
      return dependent
    end
  end
end