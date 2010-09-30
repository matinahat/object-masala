module ObjectMasala
  module Plugins
    module Properties
      include ObjectMasala::Modifiers
      module ClassMethods
        
        def properties
          @props ||= HashWithIndifferentAccess.new
        end

        def property(*args)
          p = Property.new(*args.unshift(:local))
          properties[p.name] = p
          
          create_accessors_for(p)
          create_validators_for(p)
          
          # TODO: do we need something like this, to set things up, like Arrays,
          #initialize_type(p)
        end
        
        def reference(*args)
          p = Property.new(*args.unshift(:ref))
          properties[p.name] = p
          
          if p.type == :many
            create_many_ref_for(p)
          else
            create_single_ref_for(p)
          end
          create_validators_for(p)
          initialize_type(p)
          
        end
         
        def embed(*args)
          p = Property.new(*args.unshift(:embed))
          properties[p.name] = p
          
          create_single_embedder_for(p)
          create_validators_for(p)
        end  
        
        def property?(prop)
          properties.keys.include?(prop.to_s)
        end
      
        private
        def prop_accessors_module_defined?
          if method(:const_defined?).arity == 1 # Ruby 1.9 compat check
            const_defined?('ObjectMasalaProperties')
          else
            const_defined?('ObjectMasalaProperties', false)
          end
        end
        
        def accessors_module
          if prop_accessors_module_defined?
            const_get 'ObjectMasalaProperties'
          else
            const_set 'ObjectMasalaProperties', Module.new
          end
        end
        
        def create_accessors_for(prop)
          accessors_module.module_eval <<-end_eval
            def #{prop.name}
              @doc["#{prop.name}"]
            end
          
            def #{prop.name}=(value)
              @doc["#{prop.name}"] = value
            end
          end_eval

          include accessors_module
        end
        
        def create_single_embedder_for(prop)
          accessors_module.module_eval <<-end_eval
            def #{prop.name}
              @doc["#{prop.name}"]
            end
          
            def #{prop.name}=(value)
              @doc["#{prop.name}"] = value
            end
          end_eval

          include accessors_module
        end       
      
        def create_single_ref_for(prop)
          #TODO: refs should obviously only apply to persistable models. check it, yo!
          accessors_module.module_eval <<-end_eval
            def #{prop.name}
              #{prop.options[:klass]}.first(:#{prop.options[:key]} => @doc["#{prop.name}"])
            end
          
            def #{prop.name}=(value)
              @doc["#{prop.name}"] = value["#{prop.options[:key]}"]
            end
          end_eval

          include accessors_module
        end       
        
        def create_many_ref_for(prop)
          #TODO: refs should obviously only apply to persistable models. check it, yo!
          # puts "adding #{prop.name}<br>"
          # accessors_module.module_eval <<-end_eval
          #   attr_accessor prop.name
          # end_eval
          attr_accessor prop.name.to_sym
          
          # include accessors_module
        end       
        
                 
        def create_validators_for(prop)
          attribute = prop.name.to_sym

          if prop.options[:required]
            validates_presence_of(attribute)
          end

          if prop.options[:unique]
            validates_uniqueness_of(attribute)
          end

          if prop.options[:numeric]
            number_options = prop.type == Integer ? {:only_integer => true} : {}
            validates_numericality_of(attribute, number_options)
          end

          if prop.options[:format]
            validates_format_of(attribute, :with => prop.options[:format])
          end

          if prop.options[:in]
            validates_inclusion_of(attribute, :within => prop.options[:in])
          end

          if prop.options[:not_in]
            validates_exclusion_of(attribute, :within => prop.options[:not_in])
          end

          if prop.options[:length]
            length_options = case prop.options[:length]
            when Integer
              {:minimum => 0, :maximum => prop.options[:length]}
            when Range
              {:within => prop.options[:length]}
            when Hash
              prop.options[:length]
            end
            validates_length_of(attribute, length_options)
          end
        end
        
        def initialize_type(prop)
          #TODO: make this thing work
          # puts "initializing #{prop.name} as a #{prop.type}<br>"
          # if prop.type == Array or prop.type == :many
          #   self.send("#{prop.name}=".to_sym, [])
          # end
        end
        
      end
      
      module InstanceMethods
        #TODO: this probably should be a #select of just the props that are nil
        def check_defaults
          self.class.properties.each do |name, prop|
            self.send("#{prop.name}=".to_sym, prop.default_value) if prop.scope.to_sym == :local and self.send(prop.name.to_sym).nil?
          end
        end
      end
    end
  end  
end
