module ActiveEvent
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    def self.included(base)
      super
      base.extend const_get("RegisterMethods")
    end

    module RegisterMethods
      def validation_target(target)
        ValidationsRegistry.register self, target
      end
    end
  end
end