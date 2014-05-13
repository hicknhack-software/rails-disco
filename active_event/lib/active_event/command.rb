require 'active_model'

module ActiveEvent
  class CommandInvalid < Exception
    attr_reader :record

    def initialize(record)
      self.record = record
      super 'invalid command'
    end

    private

    attr_writer :record
  end

  module Command
    extend ActiveSupport::Concern
    include ActiveEvent::Support::AttrSetter
    include ActiveModel::Validations

    module ClassMethods
      def form_name(name)
        define_singleton_method(:model_name) do
          @_model_name ||= begin
            namespace = self.parents.find do |n|
              n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
            end
            ActiveModel::Name.new(self, namespace, name)
          end
        end
      end
    end
  end
end
