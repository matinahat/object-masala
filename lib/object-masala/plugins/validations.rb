module ObjectMasala
  module Plugins
    module Validations
      def self.configure(model)
        model.class_eval do
          include Validatable
          extend Validations::Custom
        end
      end
        
      module Custom
        def validates_uniqueness_of(*args)
          add_validations(args, Validations::ValidatesUniquenessOf)
        end
      end

      class ValidatesUniquenessOf < Validatable::ValidationBase
        def valid?(instance)
          true
        end
      end
    end
  end
end