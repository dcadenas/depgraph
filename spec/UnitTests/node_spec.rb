require File.dirname(__FILE__) + "/../spec_helper"
require 'stringio'
require 'node' 
include DepGraph

describe Node do
  it 'should not accept empty uris in the constructor' do
    lambda{Node.new('')}.should raise_error
  end
  
  it 'should have a non empty name' do
    node = Node.new('a')
    node.name.should_not be_empty
  end

  it 'should be equal to another node with the same name' do
    node1 = Node.new('abc')
    node2 = Node.new('abc')
    node3 = Node.new('abd')
    
    node1.should == node2
    node1.should be_eql(node2)

    node1.should_not == node3
    node1.should_not be_eql(node3)
    
    node2.should_not == node3
    node2.should_not be_eql(node3)
  end
  
  it 'should allow setting node dependencies' do
    node = Node.new('a')
    node.depends_on('b')
    
    node.dependencies.size.should == 1
  end
  
  it 'should allow querying for a node' do
    node = Node.new('a')
    node.depends_on('b')
    
    node.depends_on?('b').should be_true
    node.depends_on?('c').should be_false
  end
end
