module ObjectMasala
  module Chainable

    # @api private
    def chainable(&block)
      mod = Module.new(&block)
      include mod
      mod
    end

    # @api private
    def extendable(&block)
      mod = Module.new(&block)
      extend mod
      mod
    end
  end
end
