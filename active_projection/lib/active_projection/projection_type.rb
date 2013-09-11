module ActiveProjection
  module ProjectionType
    extend ActiveSupport::Concern
    class WrongArgumentsCountError < StandardError
    end
    included do
      ProjectionTypeRegistry::register(self)
    end

    def initialize
      self.handlers = Hash.new do |hash, key|
        hash[key] = []
      end
      self.class.public_instance_methods(false).each do |method_name|
        method = self.class.instance_method method_name
        event_type = method_name.to_s.camelcase.to_sym
        raise WrongArgumentsCountError if 1 != method.arity
        handlers[event_type] << method.name
      end
    end

    def evaluate(headers)
      return false unless ProjectionRepository.solid? projection_id #projection is broken and shouldn't process any incoming event
      last_id = ProjectionRepository.get_last_id projection_id
      case
        when last_id + 1 == headers[:store_id] #process incoming event
          ProjectionRepository.set_last_id projection_id, headers[:store_id]
          puts "process this event"
          true
        when last_id >= headers[:store_id] #incoming event already processed
          puts "event already processed"
          false
        when last_id < headers[:store_id] #incoming event is in future, so we are missing some
          puts "events are missing"
          ProjectionRepository.set_broken projection_id
          false
      end
    end

    def invoke(event)
      event_type = event.class.name.split('::').last.to_sym
      return unless handlers.has_key? event_type
      handlers[event_type].each do |method|
        self.send method, event
      end
    end

    private
    attr_accessor :handlers
    attr_writer :projection_id

    def projection_id
      @projection_id ||= ProjectionRepository.create_or_get(self.class.name).id
    end
  end
end
