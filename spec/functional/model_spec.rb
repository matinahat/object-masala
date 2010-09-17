require File.dirname(__FILE__) + '/../spec_helper'

class MyModel
  include ObjectMasala::Model  
end

class MyModelWithAccessor
  include ObjectMasala::Model
  attr_accessor :my_attr
end


describe ObjectMasala::Model do
  before(:each) do    
    @doc = MyModel.new
  end
  
  it "should be a module" do
    ObjectMasala::Model.should be_kind_of(Module)
  end

  %w(plugin).each do |p|
    it "should respond to #{p}" do
      MyModel.should respond_to(p.to_sym)
    end  
  end
   
  %w(errors is_new is_new? new? []= [] merge == to_hash doc doc=).each do |p|
    it "should respond to #{p}" do
      @doc.should respond_to(p.to_sym)
    end  
  end
end

describe ObjectMasala::Model do
  it "should add doc attribs to the doc" do
    @doc = MyModelWithAccessor.new(:foo => 'bar')
    
    @doc[:foo].should == 'bar'
  end
  
  it "should add class attributes to the class instance, not the doc" do
    @doc = MyModelWithAccessor.new(:my_attr => 'bar')
    
    @doc.doc.keys.should_not include('my_attr')
  end
  
  it "should add both kinds of attribs" do
    @doc = MyModelWithAccessor.new(:foo => 'bar', :my_attr => 'baz')
    
    @doc[:foo].should == 'bar'
    @doc.doc.keys.should_not include('my_attr')
    @doc.my_attr.should == 'baz'
  end
  
end