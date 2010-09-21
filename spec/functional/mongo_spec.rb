require File.dirname(__FILE__) + '/../spec_helper'

class MyMongoDocument
  include ObjectMasala::MongoDocument
  
  MyMongoDocument.db = Mongo::Connection.new().db('masala')
  
  property :required_string, String, :required => true
  property :unique_string,   String, :unique => true
end

class MyMongoDocument2
  include ObjectMasala::MongoDocument
  
  collection_name 'test'
end


describe ObjectMasala::Plugins::MongoPersistence do
  before(:each) do
    MyMongoDocument.collection.drop
    
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
  
  describe '.collection_name' do
    context 'default' do
      it 'should set the collection name to the pluralized lowercase' do
        MyMongoDocument.collection_name.should == 'my_mongo_documents'
      end
    end
    
    context 'explictly set' do
      it 'should take name passed to .collection_name' do
        MyMongoDocument2.collection_name.should == 'test'
      end
    end
  end
  
  it "should persist" do
    @doc[:required_string] = "baz"
    @doc[:foo] = "bar"
    @doc.should be_valid
    @doc.insert
    MyMongoDocument.first.should == @doc
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
      @doc.insert
      MyMongoDocument.first.should == @doc

      @doc2 = MyMongoDocument.new(:required_string => @doc.required_string, :unique_string => @doc.unique_string)    
      @doc2.should_not be_valid
      @doc2.errors.on(:unique_string).should include("is already taken")
    end
  end
end