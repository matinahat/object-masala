module ObjectMasala
  module Plugins
    module HashAccessors

      module InstanceMethods
        # Set a field on this document:
        #  mydoc["name"] = "Ben"
        #  mydoc["address"] = { "city" => "San Francisco" }
        def []=(k,v)
          @doc[k.to_s] = v
        end
    
        # Fetch a field (just like a hash):
        #  mydoc["name"]
        #   => "Ben"
        def [](k)
          @doc[k.to_s]
        end
    
        # Merge this document with the supplied hash. Useful for updates:
        #  mydoc.merge(params[:user])
        def merge(hash)
          hash.each { |k,v| self[k] = v }; @doc
        end
        
      end
    end
  end
end