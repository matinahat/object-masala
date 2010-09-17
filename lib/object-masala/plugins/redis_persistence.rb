require 'redis'

module ObjectMasala
  module Plugins
    module RedisPersistence
      module ClassMethods
        def persistable?
          true
        end
       end
    end
  end
end