gem "activesupport"

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string/inflections'

module ObjectMasala
  class << self
    # Returns an instance of Mongo::DB
    def db
      @db
    end
    
    # Set to an instance of Mongo::DB to be used for all models:
    #  ObjectMasala.db = Mongo::Connection.new().db('mydb')
    def db=(obj)
      unless obj.is_a?(Mongo::DB)
        raise(ArgumentError, "Must supply a Mongo::DB object")
      end; @db = obj
    end
  end
  
  autoload :Cursor,         "object-masala/cursor"
  autoload :Modifiers,      "object-masala/modifiers"
  autoload :Document,       "object-masala/document"
  autoload :MongoDocument,  "object-masala/mongo_document"
  autoload :Model,          "object-masala/model"
  autoload :Plugins,        "object-masala/plugins"
  
  module Plugins
    autoload :Model,                   "object-masala/plugins/model"
    autoload :Properties,              "object-masala/plugins/properties"
    autoload :Property,                "object-masala/plugins/property"
    autoload :HashAccessors,           "object-masala/plugins/hash_accessors"
    autoload :Validations,             "object-masala/plugins/validations"
    autoload :MongoValidations,        "object-masala/plugins/mongo_validations"
    autoload :Hooks,                   "object-masala/plugins/hooks"
    autoload :Timestamps,              "object-masala/plugins/timestamps"
    autoload :MongoPersistence,        "object-masala/plugins/mongo_persistence"
    autoload :RedisPersistence,        "object-masala/plugins/redis_persistence"
  end
end

require 'object-masala/support/descendant_appends'
require 'object-masala/support/assertions'
require 'object-masala/support/chainable'
require 'object-masala/support/hook'
require 'object-masala/support/local_object_space'