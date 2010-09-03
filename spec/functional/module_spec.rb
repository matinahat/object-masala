require File.dirname(__FILE__) + '/../spec_helper'

describe ObjectMasala do
  describe "properties" do    
    it "should be a module" do
      ObjectMasala.should be_kind_of(Module)
    end
    
    it "should respond to db" do
      ObjectMasala.should respond_to(:db)
    end

    it "should respond to db=" do
      ObjectMasala.should respond_to(:db=)
    end
  end
end