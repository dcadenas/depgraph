require File.dirname(__FILE__) + "/spec_helper"
require 'stringio'
require 'dependent' 
require 'rubygems'
require 'spec'
include DepGraph

describe Dependent do
  it 'should not accept empty uris in the constructor' do
    lambda{Dependent.new('')}.should raise_error
  end
  
  it 'should have a non empty name' do
    dependent = Dependent.new('a')
    dependent.name.should_not be_empty
  end
  
  it 'should have the name of the file specified in the constructor excluding the extension' do
    dependent = Dependent.new('/directory1/directory2/file.name.ext')
    dependent.name.should == 'file.name'
  end
  
  it 'should be equal to another dependent with the same name' do
    dependent1 = Dependent.new('abc')
    dependent2 = Dependent.new('abc')
    dependent3 = Dependent.new('abd')
    
    dependent1.should == dependent2
    dependent1.should be_eql(dependent2)

    dependent1.should_not == dependent3
    dependent1.should_not be_eql(dependent3)
    
    dependent2.should_not == dependent3
    dependent2.should_not be_eql(dependent3)
  end
  
  it 'should allow setting dependent dependents' do
    dependent = Dependent.new('a')
    dependent.depends_on('b')
    
    dependent.dependencies.size.should == 1
  end
  
  it 'should allow querying for a dependent dependent' do
    dependent = Dependent.new('a')
    dependent.depends_on('b')
    
    dependent.depends_on?('b').should be_true
    dependent.depends_on?('c').should be_false
  end
  
  it 'should be able to get the dependencies to csproj and dll files from a string' do
    dependent = Dependent.new('a', :csproj)
    dependencies_string = 'from this string the dependable to "\\a.dir\\dependent1.csproj", \n"\\tgg.hyhy\\dependent2.dll" and "dependent3.csproj" should be found'
    
    dependent.load_dependencies_from_string(dependencies_string)

    dependent.dependencies.should == ["dependent1", "dependent2", "dependent3"]
  end
  
  it 'should be able to use a custom regexp filter to get the dependent dependencies from a string' do
    dependent = Dependent.new('a')
    dependencies_string = 'from this string the dependable to dependent.csproj \n and dependent1.dll should be found'
    dependent.dependable_filter = /\s([^\s]+)\.(csproj|dll)[^\w]/
    dependent.dependable_filter_capture_group_index = 0
    
    dependent.load_dependencies_from_string(dependencies_string)

    dependent.dependencies.should == ["dependent", "dependent1"]
  end
  
  it 'should be able to select the capture group that must be used in the dependable custom regexp filter' do
    dependent = Dependent.new('a')
    dependencies_string = 'from this string the dependable to prefix.dependent.csproj \n and prefix.dependent1.dll should be found'
    dependent.dependable_filter = /\s(prefix\.)([^\s]+)\.(csproj|dll)[^\w]/
    dependent.dependable_filter_capture_group_index = 1 
    
    dependent.load_dependencies_from_string(dependencies_string)

    dependent.dependencies.should == ["dependent", "dependent1"]
  end
  
  it 'should ignore repeated dependencies in the string' do
    dependent = Dependent.new('a', :csproj)
    dependencies_string = 'this string has only one dependable that is repeated 3 times: "\\a.dir\\dependent.csproj", \n"\\tgg.hyhy\\dependent.dll" and "dependent.csproj"'
    
    dependent.load_dependencies_from_string(dependencies_string)

    dependent.dependencies.should == ["dependent"]
  end
  
  it 'should ignore the capture group index if the dependable filter regexp has no capture groups' do
    dependent = Dependent.new('a')
    dependent.dependable_filter = /dep[0-9]/
    dependent.dependable_filter_capture_group_index = 1 
    
    dependent.load_dependencies_from_string('dep1 is in the first line \n in the second dep2')
    
    dependent.dependencies.size.should == 2
  end
end