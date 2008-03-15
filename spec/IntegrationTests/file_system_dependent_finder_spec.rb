require File.dirname(__FILE__) + "/../spec_helper"
require 'file_system_dependent_finder'
require 'rubygems'
gem 'filetesthelper'
require 'filetesthelper'
require 'spec'

include FileTestHelper
include DepGraph

describe FileSystemDependentFinder, '(integration tests)' do
  it 'should search only in the specified directories' do
      with_files('good1/file1' => '', 'good2/file2' => '', 'bad/file3' => '') do
        dependent_finder = FileSystemDependentFinder.new(non_existent_filter_type)
        dependent_finder.dirs = ['good1', 'good2']
        
        dependents = dependent_finder.get_dependents
        dependents.should == ['file1', 'file2']
      end
  end
end

#To setup the test files for each filter type, include three sample dependent files
#and make the first file, named 'a' depend on the next two, named 'b' and 'c'
test_set = {
  :ruby_requires => {'a.rb' => 'require "b"\nrequire "c"', 'dir/b.rb' => '', 'dir/c.rb' => '', 'not_a_ruby_file' => ''},
  :csproj => {'a.csproj' => '"b.csproj"\n"c.csproj"', 'dir/b.csproj' => '', 'dir/c.csproj' => '', 'not_a_csproj_file' => ''}
}
  
dependency_types.each do |filter_type|
  test_files = test_set[filter_type]
  
  describe FileSystemDependentFinder, "for #{filter_type.to_s} (integration tests)" do
    it "should find the correct number of dependents" do
      with_files(test_files) do
        dependents = FileSystemDependentFinder.new(filter_type).get_dependents
        dependents.should == ['a', 'b', 'c']
      end
    end
    it "should correctly find the dependencies from each file" do
      with_files(test_files) do
        dependent = FileSystemDependentFinder.new(filter_type).get_dependents[0]
        dependent.should_not be_nil
        dependent.dependencies.should == ['b', 'c']
      end
    end
  end
end
