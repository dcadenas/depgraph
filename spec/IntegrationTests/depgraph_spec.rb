require File.dirname(__FILE__) + "/../spec_helper"
require 'rubygems'
require 'graph_creator'

include FileTestHelper

default_graph_file = 'dependency_graph.png'
tool_name = 'depgraph'
tool_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bin', tool_name))

describe "#{tool_name} (integration tests)" do
 
  test_data = {
    :csproj => {'proj1.csproj' => '"proj2.csproj"', 'proj2.csproj' => '"proj1.csproj"'},
    :ruby_requires => {'rubyfile1.rb' => 'require "rubyfile2"', 'rubyfile2.rb' => 'require "rubyfile3"'},
    :gems => {}
  }

  DepGraph::GraphCreator.types.each do |filter_type|
    it "should create an image from the #{filter_type} dependency type" do
      test_files = test_data[filter_type]
      with_files(test_files) do
        system "ruby \"#{tool_path}\" -type #{filter_type}"
        
        non_empty_file_created(default_graph_file).should be_true
      end
    end
  end
  
  three_files_with_chained_dependencies_from_file1_to_file2_to_file3 = {'file1.csproj' => '"file2.csproj"', 'file2.csproj' => '"file3.csproj"', 'file3.csproj' => ''}
  two_files_with_one_dependency_from_file1_to_file2 = {'file1.csproj' => '"file2.csproj"', 'file2.csproj' => ''}
  it 'should not create a file when the "-from" filter does not find matches' do
    with_files(two_files_with_one_dependency_from_file1_to_file2) do
      system "ruby \"#{tool_path}\" -type csproj -from file2"
      
      File.exist?(default_graph_file).should be_false
    end
  end
  
  it 'should create a file when the "-from" filter finds matches' do
    with_files(two_files_with_one_dependency_from_file1_to_file2) do
      system "ruby \"#{tool_path}\" -type csproj -from file1"
      
      File.exist?(default_graph_file).should be_true
    end
  end
  
  it 'should not create a file when the "-to" filter does not find matches' do
    with_files(two_files_with_one_dependency_from_file1_to_file2) do
      system "ruby \"#{tool_path}\" -type csproj -to file1"
      
      File.exist?(default_graph_file).should be_false
    end
  end
  
  it 'should create a file when the "-to" filter finds matches' do
    with_files(two_files_with_one_dependency_from_file1_to_file2) do
      system "ruby \"#{tool_path}\" -type csproj -to file2"
      
      File.exist?(default_graph_file).should be_true
    end
  end
  
  it 'should exclude nodes when the "-exc" filter is used' do
    with_files(three_files_with_chained_dependencies_from_file1_to_file2_to_file3) do
      system "ruby \"#{tool_path}\" -type csproj -exc \"file2, ile3\""
      
      File.exist?(default_graph_file).should be_false #because only file1 exists
    end
  end
  
  it 'should be possible to load the test node finder found in the nodefinders directory' do
    with_files() do
      system "ruby \"#{tool_path}\" -type test"
      
      File.exist?(default_graph_file).should be_true
    end
  end
  
  it 'should be possible apply a transitive reduction to the output graph' do
    with_files() do
      system "ruby \"#{tool_path}\" -type test -trans"
      
      File.exist?(default_graph_file).should be_true
      File.exist?('temp.dot').should be_false
    end
  end
end


