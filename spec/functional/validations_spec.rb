require File.dirname(__FILE__) + '/../spec_helper'

class MyValidatableModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
  plugin ObjectMasala::Plugins::Validations
    
  property :optional_string, String
  property :required_string, String, :required => true
  property :dumb_string, String, :required => false

  property :unique_string, String, :unique => true

  property :string_with_default, String, :default => 'default value'

  property :string_with_length, String, :length => 5  
  property :string_that_should_be_an_email, String, :format => /^([a-zA-Z0-9_\.\-+])+@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/
  
  property :int, Integer  
  property :float, Float  
  property :now, DateTime  
end

describe ObjectMasala::Document do
  before(:each) do
    @doc = MyValidatableModel.new
  end

  describe "validations" do
    it "should check required props" do
      @doc.should_not be_valid
      @doc.errors.on(:required_string).should include("can't be empty")
    end
    
    it "should set default value" do
      @doc.string_with_default.should eql('default value')      
    end

    it "should do nothing if no default value" do
      @doc.dumb_string.should be_nil
    end
    
    it "should be valid if all props are good to go" do
      @doc.required_string = 'foo'
      @doc.string_that_should_be_an_email = 'mjm@aps.org'
      @doc.should be_valid
    end
    
    it "should always be unique" do
      @doc.required_string = 'foo'
      @doc.unique_string = 'bar'
      @doc.string_that_should_be_an_email = 'mjm@aps.org'
      @doc.should be_valid
      @doc.required_string = nil
      @doc.should_not be_valid      
    end
    
    it "should check the format of a bogus email" do
      @doc.required_string = 'foo'
      @doc.string_that_should_be_an_email = 'foo'
      @doc.should_not be_valid
    end    
    
    it "should check the format of another bogus email" do
      @doc.required_string = 'foo'
      @doc.string_that_should_be_an_email = 'foo@'
      @doc.should_not be_valid
    end    
    
    it "should check the format of a legit email" do
      @doc.required_string = 'foo'
      @doc.string_that_should_be_an_email = 'foo@bar.com'
      @doc.should be_valid
    end    
    
  end
end