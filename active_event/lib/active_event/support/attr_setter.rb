module ActiveEvent::Support
  # Allows to initialize and set attributes with a hash
  #
  # example:
  #   class RgbColor
  #     include ActiveEvent::AttrSetter
  #     attributes :r, :g, :b
  #   end
  #   green = RgbColor.new r: 250, g: 20, b: 20
  #   green.r = 255
  module AttrSetter
    extend ActiveSupport::Concern
    include ActiveEvent::Support::AttrInitializer

    # override to skip the freezing!
    def init_attributes(attributes)
      self.attributes = attributes.symbolize_keys
    end

    module ClassMethods
      def attributes(*args)
        super
        args.each do |attr|
          define_method "#{attr}=", lambda { |value| attributes[attr] = value }
        end
      end
    end
  end
end
