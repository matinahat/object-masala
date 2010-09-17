module ObjectMasala
  module MongoDocument
    extend Support::DescendantAppends
    
    def self.included(model)
      model.class_eval do
        extend ObjectMasala::Plugins

        plugin Plugins::Model
        plugin Plugins::HashAccessors
        plugin Plugins::Properties
        plugin Plugins::MongoPersistence
        plugin Plugins::Hooks        
        plugin Plugins::MongoValidations        
      end
      super
    end
  end
end