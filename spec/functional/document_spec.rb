require File.dirname(__FILE__) + '/../spec_helper'

class MyDocument
  include ObjectMasala::Document  
end

describe ObjectMasala::Document do
  before(:each) do    
    @doc = MyDocument.new
  end
  
  it "should be a module" do
    ObjectMasala::Document.should be_kind_of(Module)
  end

  %w(plugin).each do |p|
    it "should respond to #{p}" do
      MyDocument.should respond_to(p.to_sym)
    end  
  end
   
  %w(errors is_new validate valid? is_new? new? []= [] merge == to_hash doc doc=).each do |p|
    it "should respond to #{p}" do
      @doc.should respond_to(p.to_sym)
    end  
  end
end