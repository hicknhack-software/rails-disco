module ActiveEvent::Support
  class ForbiddenAttributesError < StandardError
  end

  class UnknownAttributeError < StandardError
  end

  # Allows to initialize attributes with a hash
  #
  # example:
  #   class RgbColor
  #     include ActiveEvent::AttrInitializer
  #     attributes :r, :g, :b
  #   end
  #   green = RgbColor.new r: 250, g: 20, b: 20
  module AttrInitializer
    extend ActiveSupport::Concern

    def initialize(*args)
      hash = (args.last.is_a?(Hash) ? args.pop : {})
      super
      check_attributes hash
      init_attributes hash
    end

    def freeze
      attributes.freeze
    end

    def attributes_except(*args)
      attributes.reject { |k,_| args.include? k }
    end

    def to_hash
      attributes.dup
    end

    module ClassMethods
      def self.extended(base)
        base.attribute_keys = []
      end

      attr_accessor :attribute_keys

      def attributes(*args)
        self.attribute_keys += args
        args.each do |attr|
          define_method attr, -> { attributes[attr] }
        end
      end
    end

    protected

    attr_accessor :attributes

    def init_attributes(attributes)
      self.attributes = attributes.dup
      freeze
    end

    private

    def check_attributes(attributes)
      return if attributes.blank?
      if attributes.respond_to?(:permitted?) and not attributes.permitted?
        raise ActiveEvent::Support::ForbiddenAttributesError
      end
      (attributes.keys - self.class.attribute_keys).each do |k|
        raise ActiveEvent::Support::UnknownAttributeError, "unknown attribute: #{k}"
      end
    end
  end
end
