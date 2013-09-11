require 'singleton'
require 'bunny'
module ActiveEvent
  class EventServer
    include Singleton

    def self.publish(event)
      type = event.class.name
      body = event.to_json
      instance.event_exchange.publish body, type: type, headers: event.store_infos
      puts "Published #{type} with #{body}"
    end

    def self.start(options)
      instance.start options
    end

    def start(options)
      self.options = options
      event_connection.start
      listen_for_resend_requests
    end

    def self.resend_events_after(id)
      events = EventRepository.after_id(id).to_a
      events.each do |e|
        event = EventType.create_instance(e.event, e.data.deep_symbolize_keys)
        event.add_store_infos store_id: e.id
        self.publish event
      end
    end

    def listen_for_resend_requests
      event_channel.queue('', auto_delete: true).bind(resend_exchange, routing_key: 'resend').subscribe do |delivery_info, properties, id|
        puts "received resend request with id #{id}"
        self.class.resend_events_after id
      end
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
      @resend_exchange ||= event_channel.direct "resend_#{options[:event_exchange]}"
    end

    def options
      @options
    end

    private
    attr_writer :options
  end
end