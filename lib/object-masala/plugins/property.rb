module ObjectMasala
  module Plugins
    class Property
      attr_accessor :name, :type, :options, :default_value

      def initialize(*args)
        options = args.extract_options!
        @name, @type = args.shift.to_s, args.shift
        
        self.options = (options || {}).symbolize_keys
        self.default_value = self.options[:default]
      end

      def ==(other)
        @name == other.name && @type == other.type
      end

      def number?
        [Integer, Float].include?(type)
      end
      
      def required?
        self.options.key?(:required) and self.options[:required]        
      end
      
      def unique?
        self.options.key?(:unique) and self.options[:unique]        
      end
    
      def get(value)
        # if value.nil? && !default_value.nil?
        #   if default_value.respond_to?(:call)
        #     return default_value.call
        #   else
        #     return default_value
        #   end
        # end

        type.from_mongo(value)
      end

      def set(value)
        type.to_mongo(value).tap do |values|
          if options[:typecast].present?
            values.map! { |v| typecast_class.to_mongo(v) }
          end
        end
      end
      
      private
        def typecast_class
          @typecast_class ||= options[:typecast].constantize
        end
    end
  end
end