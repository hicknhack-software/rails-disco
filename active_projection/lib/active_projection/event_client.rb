require 'singleton'
require 'bunny'
module ActiveProjection
  class EventClient
    include Singleton

    def self.start(options)
      instance.options = options
      instance.start
    end

    def start
      event_connection.start
      sync_projections
      listen_for_events
      request_missing_events
      event_channel.work_pool.join
    rescue Interrupt
      LOGGER.info 'Catching Interrupt'
    rescue Exception => e
      LOGGER.error e.message
      LOGGER.error e.backtrace.join("\n")
      raise e
    end

    def sync_projections
      ProjectionTypeRegistry.sync_projections
    end

    def listen_for_events
      subscribe_to event_queue do |delivery_info, properties, body|
        event_received properties, body
        send_browser_notification properties.headers[:id]
      end
    end

    def request_missing_events
      listen_for_replayed_events
      send_request_for min_last_id
    end

    def listen_for_replayed_events
      subscribe_to replay_queue do |delivery_info, properties, body|
        event_received properties, body unless replay_done? body
      end
    end

    def send_browser_notification(id)
      server_side_events_exchange.publish id.to_s
    end

    def send_request_for(id)
      resend_request_exchange.publish id.to_s, routing_key: 'resend_request'
    end

    def replay_done?(body)
      if 'replay_done' == body
        LOGGER.debug 'All replayed events received'
        broken_projections = ProjectionRepository.get_all_broken
        LOGGER.error "These projections are still broken: #{broken_projections.join(", ")}" unless broken_projections.empty?
        replay_queue.unbind(resend_exchange)
        return true
      end
      false
    end

    def event_received(properties, body)
      RELOADER.execute_if_updated
      LOGGER.debug "Received #{properties.type} with #{body}"
      ProjectionTypeRegistry.process properties.headers.deep_symbolize_keys!, build_event(properties.type, JSON.parse(body))
    end

    def build_event(type, data)
      Object.const_get(type).new(data.deep_symbolize_keys)
    end

    def replay_queue
      @replay_queue ||= event_channel.queue('', auto_delete: true).bind(resend_exchange)
    end

    def event_queue
      @event_queue ||= event_channel.queue('', auto_delete: true).bind(event_exchange)
    end

    def min_last_id
      ProjectionRepository.last_ids.min || 0
    end

    def subscribe_to(queue, &block)
      queue.subscribe(&block)
    end

    def event_connection
      @event_server ||= Bunny.new URI::Generic.build(options[:event_connection]).to_s
    end

    def event_channel
      @event_channel ||= event_connection.create_channel
    end

    def event_exchange
      @event_exchange ||= event_channel.fanout options[:event_exchange]
    end

    def resend_exchange
      @resend_exchange ||= event_channel.fanout "resend_#{options[:event_exchange]}"
    end

    def resend_request_exchange
      @resend_request_exchange ||= event_channel.direct "resend_request_#{options[:event_exchange]}"
    end

    def server_side_events_exchange
      @server_side_events_exchange ||= event_channel.fanout "server_side_#{options[:event_exchange]}"
    end

    def options
      @options
    end

    attr_writer :options
  end
end