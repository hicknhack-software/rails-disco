module ActiveEvent
  class ValidationsRegistry

    def self.register(validations, target)
      self.bindings << {validation: validations, target: target}
    end

    def self.build
      self.bindings.freeze.each do |binding|
        Object.const_get(binding[:target].to_s).send :include, binding[:validation]
      end
    end

    private
    cattr_accessor :bindings
    self.bindings = []
  end
end
