module ObjectMasala
  module Document
    extend Support::DescendantAppends
    
    def self.included(model)
      model.class_eval do
        extend ObjectMasala::Plugins

        plugin Plugins::Model
        plugin Plugins::HashAccessors
        plugin Plugins::Properties
        plugin Plugins::Validations        
      end
      super
    end
  end
end