require 'drb/drb'

module ActiveDomain
  module CommandProcessor
    extend ActiveSupport::Concern
    include DRb::DRbUndumped

    module ClassMethods
      protected

      def process(clazz, method_name = nil, &block)
        method_name ||= "process#{clazz.name.split('::').last}"
        define_method(method_name, &block)
        CommandRoutes.route clazz, self, method_name
      end
    end

    protected

    def event(event)
      store event
      publish event
      invoke event
      event.store_infos[:store_id]
    end

    private

    def invoke(event)
      ProjectionRegistry.invoke event
    end

    def store(event)
      EventRepository.store event
    end

    def publish(event)
      ActiveEvent::EventServer.publish event
    end
  end
end
