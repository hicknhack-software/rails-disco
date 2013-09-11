module ActiveEvent
  module EventType
    extend ActiveSupport::Concern
    include ActiveEvent::Support::AttrInitializer

    def event_type
      self.class.name
    end

    def self.create_instance(type, data)
      Object.const_get(type).new(data)
    rescue NameError
      require 'ostruct'
      OpenStruct.new(data.merge(event_type: type.to_s)).freeze
    end

    def add_store_infos(hash)
      store_infos.merge! hash
    end

    def store_infos
      @store_infos ||= {}
    end

    private
    attr_writer :store_infos

  end
end
