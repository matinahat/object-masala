gem "bson", ">= 1.0.4"
gem "bson_ext", ">= 1.0.4"
gem "mongo", ">= 1.0.7"
require "bson"
require "mongo"

module ObjectMasala
  module Plugins
    module MongoPersistence
      include ObjectMasala::Modifiers

      module ClassMethods        
        # Returns this models own db attribute if set, otherwise will return ObjectMasala.db
        def db
          @db || raise(ArgumentError, "No db supplied")
        end
      
        # Override ObjectMasala.db with a Mongo::DB instance for this model specifically
        #  MyModel.db = Mongo::Connection.new().db('mydb_mymodel')
        def db=(obj)
          unless obj.is_a?(Mongo::DB)
            raise(ArgumentError, "Must supply a Mongo::DB object")
          end; @db = obj
        end

        def collection_name=(name)
          @collection_name = name
        end

        # Override this method on your model if you want to use a different collection name
        def collection_name(name=nil)
          @collection_name ||= name.nil? ? self.to_s.tableize : name
        end
        
        # Return the raw MongoDB collection for this model
        def collection
          @collection ||= self.db.collection(self.collection_name)
        end

        # Query MongoDB for documents. Same arguments as http://api.mongodb.org/ruby/current/Mongo/Collection.html#find-instance_method
        def find(query={}, opts={})
          ObjectMasala::Cursor.new(self, collection.find(query, opts))
        end
      
        # Query MongoDB and return one document only. Same arguments as http://api.mongodb.org/ruby/current/Mongo/Collection.html#find_one-instance_method
        def find_one(query={}, opts={})
          return nil unless doc = self.collection.find_one(query, opts)
          
          self.new(doc, false)
        end
      
        # Return a ObjectMasala::Cursor instance of all documents in the collection.
        def all
          find
        end
      
        # Iterate over all documents in the collection (uses a ObjectMasala::Cursor)
        def each
          find.each { |found| yield(found) }
        end
      
        # Return the first document in the collection
        # def first
        #   find.limit(1).next_document
        # end
        def first(query={}, opts={})
          return nil unless doc = self.collection.find_one(query, opts)
          self.new(doc, false)
        end
      
        # Return the number of documents in the collection
        def count
          find.count
        end
      end
    
      
      module InstanceMethods
        attr_accessor :removed, :is_new, :errors

        def initialize(doc={}, is_new=true)
          refs = {}
          embeds = {}
          
          if self.class.plugins.include?(ObjectMasala::Plugins::Properties)
            doc.each do |k,v|
              if self.class.properties.key?(k) and self.class.properties[k].scope.to_sym != :local
                if self.class.properties[k].scope.to_sym == :ref
                  refs[k] = doc.delete(k)
                elsif self.class.properties[k].scope.to_sym == :embed
                  embeds[k] = doc.delete(k)                  
                end
              else
                self.send("#{k}=".to_sym, doc.delete(k)) if self.respond_to?("#{k}=".to_sym) and not self.class.properties.key?(k)
              end
            end
          else
            doc.each do |k,v|
              self.send("#{k}=".to_sym, doc.delete(k)) if self.respond_to?("#{k}=".to_sym)
            end
          end
          
          @doc = doc.stringify_keys
          
          refs.each do |k,v|
            if is_new
              self.send("#{k}=".to_sym, v)
            else
              @doc[k] = v
            end

          end
          
          self.removed = false
          self.is_new  = is_new
          self.check_defaults if self.respond_to?(:check_defaults)          
        end
        
        def persistable?
          true
        end
            
        def is_new?
          self.is_new == true
        end
    
        def new?
          self.is_new == true
        end
        
        # Will return true if the document has been removed.
        def removed?
          self.removed == true
        end
    
        # Check equality with another ObjectMasala document
        def ==(obj)
          obj.is_a?(self.class) && obj.doc["_id"] == @doc["_id"]
        end

        # Reload the document from the database
        def reload
          if obj = self.class.find({"_id" => @doc["_id"]}).next_document
            @doc = obj.doc; true
          end
        end
        
        def save(opts={})
          result = new? ? insert(opts) : update(opts)
          result
        end

        # Insert the document into the database. Will return false if the document has
        # already been inserted or is invalid. Returns the generated BSON::ObjectID
        # for the new document. Will silently fail if MongoDB is unable to insert the
        # document, use insert! if you want an error raised instead. Note that this will
        # require an additional call to the db.
        def insert(opts={})
          return false unless new? && valid?
          self.send(:before_insert) if self.respond_to?(:before_insert)
          self.send(:before_insert_or_update) if self.respond_to?(:before_insert_or_update)
          if ret = self.class.collection.insert(@doc,opts)
            @doc["_id"] = @doc.delete(:_id) if @doc[:_id]
            self.is_new = false
          end
          self.send(:after_insert) if self.respond_to?(:after_insert)
          self.send(:after_insert_or_update) if self.respond_to?(:after_insert_or_update)
          ret
        end
    
        # Calls insert(...) with {:safe => true} passed in as an option. Will check MongoDB
        # after insert to make sure that the insert was successful, and raise a Mongo::OperationError
        # if there were any problems.
        def insert!(opts={})
          insert(opts.merge(:safe => true))
        end
    
        # Will persist any changes you have made to the document. Will silently fail if
        # MongoDB is unable to update the document, use update! instead if you want an
        # error raised. Note that this will require an additional call to the db.
        def update(opts={},update_doc=@doc)
          return false if new? || removed? || !valid?
          self.send(:before_update) if self.respond_to?(:before_update)
          self.send(:before_insert_or_update) if self.respond_to?(:before_insert_or_update)
          ret = self.class.collection.update({"_id" => @doc["_id"]}, update_doc, opts)
          self.send(:after_update) if self.respond_to?(:after_update)
          self.send(:after_insert_or_update) if self.respond_to?(:after_insert_or_update)
          ret
        end
    
        # Same as update(...) but will raise a Mongo::OperationError in case of any issues.
        def update!(opts={},update_doc=@doc)
          update(opts.merge(:safe => true),update_doc)
        end
    
        # Remove this document from the collection. Silently fails on error, use remove!
        # if you want an exception raised.
        def remove(opts={})
          return false if new?
          self.send(:before_remove) if self.respond_to?(:before_remove)
          if ret = self.class.collection.remove({"_id" => @doc["_id"]})
            self.removed = true; freeze; ret
          end
          self.send(:after_remove) if self.respond_to?(:after_remove)
          ret
        end
    
        # Like remove(...) but raises Mongo::OperationError if MongoDB is unable to
        # remove the document.
        def remove!(opts={})
          remove(opts.merge(:safe => true))
        end
    
        # Return this document as a hash.
        def to_hash
          @doc || {}
        end    
      end
    end
  end
end