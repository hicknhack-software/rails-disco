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
        raise WrongArgumentsCountError if 2 < method.arity or method.arity < 1
        event_type = ProjectionType.method_name_to_event_type method_name
        handlers[event_type] << [method_name, method.arity]
      end
    end

    def evaluate(headers)
      return false unless solid? || headers[:replayed]
      last_id = fetch_last_id
      event_id = headers[:id]
      case
        when last_id + 1 == event_id
          true
        when last_id >= event_id
          puts "[#{self.class.name}] event #{event_id} already processed"
          false
        when last_id < event_id
          set_broken
          puts "[#{self.class.name}] #{event_id - last_id} events are missing"
          false
      end
    end

    def invoke(event, headers)
      event_id = headers[:id]
      event_type = event.class.name.to_sym
      handlers[event_type].each do |method, arity|
        begin
          if 1 == arity
            self.send method, event
          else
            self.send method, event, headers
          end
        rescue Exception
          puts "[#{self.class.name}] error processing #{event_type}[#{event_id}]"
          raise
        end
      end
      update_last_id event_id
      puts "[#{self.class.name}] sucessfully processed #{event_type}[#{event_id}]"
    end

    private
    attr_accessor :handlers
    attr_writer :projection_id

    def self.method_name_to_event_type(method_name)
      (method_name.to_s.gsub('__', '/').camelcase + 'Event').to_sym
    end
 
    def projection_id
      @projection_id ||= ProjectionRepository.create_or_get(self.class.name).id
    end

    def solid?
      ProjectionRepository.solid? projection_id
    end

    def fetch_last_id
      ProjectionRepository.get_last_id projection_id
    end

    def set_broken
      ProjectionRepository.set_broken projection_id
    end

    def update_last_id(id)
      ProjectionRepository.set_last_id projection_id, id
    end
  end
end
