require 'singleton'
require 'bunny'
module ActiveEvent
  class EventServer
    include Singleton

    def self.publish(event)
      type = event.class.name
      body = event.to_json
      instance.event_exchange.publish body, type: type, headers: event.store_infos
      LOGGER.debug "Published #{type} with #{body}"
    end

    def self.start(options)
      instance.options = options
      instance.start
    end

    def start
      event_connection.start
      listen_for_resend_requests
    end

    def resend_events_after(id)
      if @replay_server_thread.nil? || !@replay_server_thread.alive?
        @replay_server_thread = Thread.new do
          Thread.current.priority = -10
          ReplayServer.start options, id
        end
      else
        ReplayServer.update id
      end
    end

    def listen_for_resend_requests
      resend_request_queue.subscribe do |delivery_info, properties, id|
        resend_request_received id
      end
    end

    def resend_request_received (id)
      LOGGER.debug "received resend request with id #{id}"
      resend_events_after id.to_i
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

    def resend_request_exchange
      @resend_request_exchange ||= event_channel.direct "resend_request_#{options[:event_exchange]}"
    end

    def resend_request_queue
      @resend_request_queue ||= event_channel.queue('', auto_delete: true).bind(resend_request_exchange, routing_key: 'resend_request')
    end

    def options
      @options
    end

    attr_writer :options
  end
end