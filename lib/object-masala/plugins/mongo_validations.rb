module ObjectMasala
  module Plugins
    module MongoValidations
      def self.configure(model)
        model.class_eval do
          include Validatable
          extend MongoValidations::Custom
        end
      end
        
      module Custom
        def validates_uniqueness_of(*args)
          add_validations(args, MongoValidations::ValidatesUniquenessOf)
        end
      end

      class ValidatesUniquenessOf < Validatable::ValidationBase
        option :scope, :case_sensitive
        default :case_sensitive => true

        def valid?(instance)
          value = instance[attribute]
          return true if value.blank?
          return true if value.nil?
          base_conditions = case_sensitive ? {self.attribute => value} : {}
          doc = instance.class.find_one(base_conditions.merge(scope_conditions(instance)).merge(where_conditions(instance)))
          # doc.nil? || instance._id == doc._id
          doc.nil? || instance == doc
        end

        def message(instance)
          super || "is already taken"
        end

        def scope_conditions(instance)
          return {} unless scope
          Array(scope).inject({}) do |conditions, key|
            conditions.merge(key => instance[key])
          end
        end

        def where_conditions(instance)
          conditions = {}
          conditions[attribute] = /^#{Regexp.escape(instance[attribute].to_s)}$/i unless case_sensitive
          conditions
        end
      end
    end
  end
end