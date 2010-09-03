require File.dirname(__FILE__) + '/../spec_helper'

class MyMongoDocument
  include ObjectMasala::MongoDocument
  
  MyMongoDocument.db = Mongo::Connection.new().db('masala')
  MyMongoDocument.collection_name = 'test'
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
  
  it "should persist" do
    @doc[:foo] = "bar"
    @doc.insert
    MyMongoDocument.first.should == @doc
  end
end