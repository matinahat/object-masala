require File.dirname(__FILE__) + '/../spec_helper'

class MyModel
  include ObjectMasala::Model  
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