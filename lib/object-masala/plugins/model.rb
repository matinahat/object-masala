module ObjectMasala
  module Plugins
    module Model

      module ClassMethods
      end
          
      module InstanceMethods
        attr_accessor :is_new, :errors

        def initialize(doc={}, is_new=true)
          if self.class.plugins.include?(ObjectMasala::Plugins::Properties)
            doc.each do |k,v|
              self.send("#{k}=".to_sym, doc.delete(k)) if self.respond_to?("#{k}=".to_sym) and not self.class.properties.key?(k)
            end
          else
            doc.each do |k,v|
                self.send("#{k}=".to_sym, doc.delete(k)) if self.respond_to?("#{k}=".to_sym)
            end
          end
          
          @doc = doc.stringify_keys
          self.is_new  = is_new
          self.check_defaults if self.respond_to?(:check_defaults)
        end

        def persistable?
          false
        end
    
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