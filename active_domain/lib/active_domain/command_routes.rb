module ActiveDomain
  class CommandRoutes
    def version
      '0.1.0'
    end

    def initialize
      self.processors = {}
    end

    def run_command(command)
      processor, method = @@routes[command.class]
      processor_instance(processor).method(method).call(command)
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