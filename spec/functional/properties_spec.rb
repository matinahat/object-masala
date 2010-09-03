require File.dirname(__FILE__) + '/../spec_helper'

class MyPropertyModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  property :basic, String
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