require File.dirname(__FILE__) + '/../spec_helper'

class MyPropertyModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  property :mid, String
end

class MyMongoPropertyModel
  include ObjectMasala::MongoDocument
  
  MyMongoPropertyModel.db = Mongo::Connection.new().db('masala')
  MyMongoPropertyModel.collection_name = 'test'
    
  property :mid, String
end

class MySingleReferenceModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  reference :ref, :one, :key => :mid, :klass => MyMongoPropertyModel
end

class MyManyReferenceModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  reference :refs, :many, :key => :mid, :klass => MyMongoPropertyModel
end

class MySingleEmbedModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  embed :embedded, :one, :klass => MyPropertyModel
end

class MyManyEmbedModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  embed :embeddeds, :one, :klass => MyPropertyModel
end

class MyPropertyModelWithAccessor
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  property :basic, String
  attr_accessor :my_attr
end

class MyFullPropertyModel
  include ObjectMasala::Model
  plugin ObjectMasala::Plugins::Properties
    
  property :basic, String
  attr_accessor :my_attr
  
  reference :ref,       :one,  :klass => MyPropertyModel, :key => :mid
  reference :refs,      :many, :klass => MyPropertyModel, :key => :mid
  embed     :embedded,  :one,  :klass => MyPropertyModel
  embed     :embeddeds, :many, :klass => MyPropertyModel
end

describe ObjectMasala::Document do
  before(:each) do
    MyMongoPropertyModel.collection.drop
    @doc = MyPropertyModel.new
  end
    
  describe "properties" do
    it "should respond to :id=" do
      @doc.should respond_to(:mid=)
    end  
    
    it "should have properties" do
      @doc.mid = 'foo'
      @doc.mid.should eql('foo')
    end
    
    it "should have hash access" do
      @doc['mid'] = 'foo'
      @doc.mid.should eql('foo')
      @doc['mid'].should eql('foo')
      
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
  
  it "should set the value of a single reference prop to the key" do
    @ref = MyMongoPropertyModel.new(:mid => 'foo')
    @ref.save
    
    @doc = MySingleReferenceModel.new
    @doc.ref = @ref

    @doc.ref.should == @ref
  end
  
  it "should push the value of a many reference prop to an array" do
    @ref1 = MyMongoPropertyModel.new(:mid => 'foo')
    @ref1.save
  
    @ref2 = MyMongoPropertyModel.new(:mid => 'bar')
    @ref2.save
    
    # @doc = MyManyReferenceModel.new
    # @doc.refs << @ref1
    # @doc.refs << @ref2
  
    @doc.save
    # @doc.ref.should == @ref
  end
  
end