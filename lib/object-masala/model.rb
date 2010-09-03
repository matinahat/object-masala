module ObjectMasala
  module Model
    extend Support::DescendantAppends
    
    def self.included(model)
      model.class_eval do
        extend ObjectMasala::Plugins

        plugin Plugins::Model
        plugin Plugins::HashAccessors
      end
      super
    end
  end
end