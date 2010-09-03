# gem "bson", ">= 1.0.4"
# gem "bson_ext", ">= 1.0.4"
# gem "mongo", ">= 1.0.7"
gem "activesupport"

# require "bson"
# require "mongo"

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'

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
    autoload :Timestamps,              "object-masala/plugins/timestamps"
    autoload :MongoPersistence,        "object-masala/plugins/mongo_persistence"
    autoload :RedisPersistence,        "object-masala/plugins/redis_persistence"
  end
end

require 'object-masala/support/descendant_appends'