require 'singleton'
require 'bunny'
module ActiveProjection
  class EventClient
    include Singleton

    def self.start(options)
      instance.start options
    end

    def start(options)
      self.options = options
      event_connection.start
      begin
        event_channel.queue('', auto_delete: true).bind(event_exchange).subscribe do |delivery_info, properties, body|
          puts "Received #{properties.type} with #{body}"
          ProjectionTypeRegistry.process(properties.headers.deep_symbolize_keys, Object.const_get(properties.type).new((JSON.parse body).deep_symbolize_keys))
        end
      rescue Interrupt => _
        event_channel.close
        event_connection.close
      end
      last_ids = ProjectionRepository.all.to_a.map { |p| p.last_id }
      request_events_after last_ids.min || 0
      event_channel.work_pool.join
    end

    def request_events_after(id)
      resend_exchange.publish id.to_s, routing_key: 'resend'
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