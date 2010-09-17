require File.dirname(__FILE__) + '/../spec_helper'

class MyPropertyModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  property :basic, String
  attr_accessor :is_new, :errors
end

class MyPropertyModelWithAccessor
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  property :basic, String
  attr_accessor :my_attr
end


describe ObjectMasala::Document do
  before(:each) do
    @doc = MyPropertyModel.new
  end
    
  describe "properties" do
    it "should respond to :basic=" do
      @doc.should respond_to(:basic=)
    end  
    
    it "should have properties" do
      @doc.basic = 'foo'
      @doc.basic.should eql('foo')
    end
    
    it "should have hash access" do
      @doc['basic'] = 'foo'
      @doc.basic.should eql('foo')
      @doc['basic'].should eql('foo')
      
    end    
  end
end

describe ObjectMasala::Document do
  it "should add doc attribs to the doc" do
    @doc = MyPropertyModelWithAccessor.new(:basic => 'foo')
    
    @doc.basic.should eql('foo')
  end
  
  it "should add class attributes to the class instance, not the doc" do
    @doc = MyPropertyModelWithAccessor.new(:my_attr => 'bar')
    
    @doc.doc.keys.should_not include('my_attr')
  end
  
  it "should add both kinds of attribs" do
    @doc = MyPropertyModelWithAccessor.new(:basic => 'foo', :my_attr => 'baz')
    
    @doc.basic.should eql('foo')
    @doc.doc.keys.should_not include('my_attr')
    @doc.my_attr.should == 'baz'
  end
  
end