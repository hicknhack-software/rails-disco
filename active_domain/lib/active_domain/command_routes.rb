require 'active_event/domain'

module ActiveDomain
  class CommandRoutes
    def version
      '0.1.0'
    end

    def initialize
      self.processors = {}
    end

    def run_command(command)
      RELOADER.execute_if_updated
      processor, method = @@routes[command.class]
      processor_instance(processor).method(method).call(command)
    rescue Exception => e
      LOGGER.error e.message
      LOGGER.error e.backtrace.join("\n")
      raise ActiveEvent::DomainExceptionCapture, ["#{e.class.name}: #{e.message}", e.backtrace].to_json, e.backtrace
    end

    def self.route(type, processor, method)
      @@routes[type] = [processor, method]
    end

    private

    attr_accessor :processors

    def processor_instance(processor)
      processors[processor] ||= processor.new
    end

    @@routes = {}
  end
end
