module ObjectMasala
  module Plugins
    module Model

      module ClassMethods
      end
          
      module InstanceMethods
        attr_accessor :is_new, :errors

        def initialize(doc={}, is_new=true)
          @doc = doc.stringify_keys
          self.is_new  = is_new
          # self.errors  = ObjectMasala::Errors.new
          
          self.check_defaults if self.respond_to?(:check_defaults)
        end
    
        # Override this with your own validate() method for validations.
        # Simply push your errors into the self.errors property and
        # if self.errors remains empty your document will be valid.
        #  def validate
        #    self.errors << ["name", "cannot be blank"]
        #  end
        # def validate
        #   true
        # end
    
        # def valid?
        #   self.errors = ObjectMasala::Errors.new
        #   self.send(:before_validate) if self.respond_to?(:before_validate)
        #   validate
        #   self.send(:after_validate) if self.respond_to?(:after_validate)
        #   self.errors.empty?
        # end
    
        def is_new?
          self.is_new == true
        end
    
        def new?
          self.is_new == true
        end
            
        # Check equality with another ObjectMasala document
        def ==(obj)
          obj.is_a?(self.class) && obj.doc["_id"] == @doc["_id"]
        end
    
        # Return this document as a hash.
        def to_hash
          @doc || {}
        end
    
        def doc
          @doc
        end
    
        def doc=(v)
          @doc = v
        end
                
      end
    end
  end
end