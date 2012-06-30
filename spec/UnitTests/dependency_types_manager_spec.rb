require File.dirname(__FILE__) + "/../spec_helper"
require 'dependency_types_manager'
include DepGraph

describe DependencyTypesManager do
  
  it "should return the available filter types" do
    dependency_types_in_file = YAML.load_file(DependencyTypesManager.dependency_types_file).map do |filter_type_in_file, _| 
      filter_type_in_file
    end
    
    dependency_types_in_file.should == dependency_types.map {|filter_type| filter_type.to_s}
  end
  
  it "should use default values if the specified filter type is not found" do
    dependable_filter_manager = DependencyTypesManager.new non_existent_filter_type
    
    dependable_filter_manager.dependable_regexp.should == /.+/
    dependable_filter_manager.dependable_regexp_capture_group_index.should == 0
    dependable_filter_manager.file_name_pattern.should == '*'
  end


  sample_contents = {
    :ruby_requires => {:content => ['require "something/dependency"',
                           "  require   'something/dependency.rb'"],
              :file_pattern => '*.rb'},
            
    :csproj => {:content => ['sdff "directory\\dependency.csproj"hyhyhy',
                             'asdfffd"directory\\anotherdir\\dependency.dll" gfgfgg'],
                :file_pattern => '*.csproj'}
  }

  dependency_types.each do |filter_type|
    it "should have a #{filter_type} filter type" do
      dependable_filter_manager = DependencyTypesManager.new filter_type
    
      capture_index = dependable_filter_manager.dependable_regexp_capture_group_index
      sample_contents[filter_type][:content].each do |sample_dependency|
          dependable_filter_manager.dependable_regexp.match(sample_dependency).captures[capture_index].should == 'dependency'
      end
      dependable_filter_manager.file_name_pattern.should == sample_contents[filter_type][:file_pattern]
    end
  end
end

