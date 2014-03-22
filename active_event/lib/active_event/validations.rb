module ActiveEvent
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    def self.included(base)
      super
      base.extend const_get('RegisterMethods')
    end

    module RegisterMethods
      def skip_validate(*args)
        options = args.extract_options!
        if options.key?(:on)
          options = options.dup
          options[:if] = Array(options[:if])
          options[:if].unshift("validation_context == :#{options[:on]}")
        end
        args << options
        skip_callback(:validate, *args)
      end

      def skip_validates(*attributes)
        defaults = attributes.extract_options!.dup
        validations = defaults.slice!(*_validates_default_keys)

        return if attributes.empty?
        return if validations.empty?

        defaults[:attributes] = attributes

        validations.each do |key, options|
          next unless options
          key = "#{key.to_s.camelize}Validator"

          begin
            validator = key.include?('::') ? key.constantize : const_get(key)
          rescue NameError
            raise ArgumentError, "Unknown validator: '#{key}'"
          end

          skip_validates_with(validator, defaults.merge(_parse_validates_options(options)))
        end
      end

      def skip_validates_with(*args)
        options = args.extract_options!
        args.each do |klass|
          validator = klass.new(options)

          if validator.respond_to?(:attributes) && !validator.attributes.empty?
            validator.attributes.each do |attribute|
              _validators[attribute.to_sym].reject! { |x| x.instance_of? klass } if _validators.key? attribute.to_sym
            end
          else
            _validators[nil].reject! { |x| x.instance_of? klass }
          end

          skip_validate(validator, options)
        end
      end

      def validation_target(target)
        ValidationsRegistry.register self, target
      end
    end
  end
end
