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

    def is_valid_do(&block)
      valid = valid?
      block.call() if valid
      valid
    end
  end
end
