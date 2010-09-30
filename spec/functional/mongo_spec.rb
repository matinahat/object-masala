require File.dirname(__FILE__) + '/../spec_helper'

class MyMongoDocument
  include ObjectMasala::MongoDocument
  
  MyMongoDocument.db = Mongo::Connection.new().db('masala')
  
  property :optional_string, String
  property :required_string, String, :required => true
  property :unique_string,   String, :unique => true
  
end

class MySingleReferenceMongoDocument
  include ObjectMasala::MongoDocument
  
  MySingleReferenceMongoDocument.db = Mongo::Connection.new().db('masala')
    
  reference :ref, :one, :key => :required_string, :klass => MyMongoDocument
end


describe ObjectMasala::Plugins::MongoPersistence do
  before(:each) do
    MyMongoDocument.collection.drop
    MySingleReferenceMongoDocument.collection.drop
    
    @doc = MyMongoDocument.new    
  end
  
  %w(plugin db db= collection_name= collection_name collection find find_one all each first count).each do |p|
    it "should respond to #{p}" do
      MyMongoDocument.should respond_to(p.to_sym)
    end  
  end
   
  %w(errors is_new removed validate valid? is_new? new? []= [] merge removed? == reload insert insert! update update! remove remove! to_hash doc doc=).each do |p|
    it "should respond to #{p}" do
      @doc.should respond_to(p.to_sym)
    end  
  end
  
  it "should persist" do
    @doc[:required_string] = "baz"
    @doc[:foo] = "bar"
    @doc.should be_valid
    @doc.save
    MyMongoDocument.first.should == @doc
  end
  
  it "should find by passing thru options" do
    @doc[:required_string] = "baz"
    @doc[:foo] = "bar"
    @doc.should be_valid
    @doc.save
    MyMongoDocument.first(:foo => 'bar').should == @doc
  end
  
  
  describe "validations" do
    it "should check required props" do
      @doc.should_not be_valid
      @doc.errors.on(:required_string).should include("can't be empty")
    end
    
    it "should check uniqueness" do
      @doc[:required_string] = "baz"
      @doc[:unique_string] = "bar"
      @doc.should be_valid
      @doc.save
      MyMongoDocument.first.should == @doc

      @doc2 = MyMongoDocument.new(:required_string => @doc.required_string, :unique_string => @doc.unique_string)    
      @doc2.should_not be_valid
      @doc2.errors.on(:unique_string).should include("is already taken")
      
    end    
  end
  
  describe "references" do
    it "should set the value of a single reference prop to the key" do
      @ref = MyMongoDocument.new(:required_string => 'foo')    
      @ref.save

      @doc = MySingleReferenceMongoDocument.new
      @doc.ref = @ref

      @doc.ref.should == @ref
      @doc.should be_valid
      @doc.save.should be_true
      @doc.ref.required_string.should == @ref.required_string
    end
    
    it "should set the value of a single reference prop to the key via the constructor" do
      @ref = MyMongoDocument.new(:required_string => 'foo')    
      @ref.save

      @doc = MySingleReferenceMongoDocument.new(:ref => @ref)
      @doc.ref = @ref

      @doc.ref.should == @ref
      @doc.should be_valid
      @doc.save.should be_true
      @doc.ref.required_string.should == @ref.required_string
    end
    
  end
end